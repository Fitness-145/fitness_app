import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  DateTime selectedDate = DateTime.now();
  int currentPage = 1;
  final int itemsPerPage = 5;
  List<Map<String, dynamic>> attendanceData = [];
  Map<String, int> attendanceCounts = {};
  bool isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _listenToAttendanceCounts(); // Start real-time listener
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    try {
      await _fetchAttendance();
    } catch (e) {
      _showSnackBar('Error fetching data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchAttendance() async {
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      final startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
      final isCurrentMonth =
          selectedDate.year == DateTime.now().year &&
          selectedDate.month == DateTime.now().month;
      final endOfMonth = DateTime(selectedDate.year, selectedDate.month + 1, 0);
      final calculationEndDate = isCurrentMonth
          ? DateTime.now().isAfter(selectedDate)
              ? selectedDate
              : DateTime.now()
          : endOfMonth;

      final attendanceSnapshot = await _firestore
          .collection('attendance')
          .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
          .where('timestamp', isLessThanOrEqualTo: calculationEndDate)
          .get();

      final dailyAttendanceSnapshot = await _firestore
          .collection('attendance')
          .where('timestamp',
              isGreaterThanOrEqualTo:
                  DateTime(selectedDate.year, selectedDate.month, selectedDate.day))
          .where('timestamp',
              isLessThan:
                  DateTime(selectedDate.year, selectedDate.month, selectedDate.day + 1))
          .get();

      List<Map<String, dynamic>> tempData = [];
      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final userId = userDoc.id;
        final name = userData['name'] ?? 'Unknown';

        // Daily attendance status
        final isPresent =
            dailyAttendanceSnapshot.docs.any((doc) => doc['userId'] == userId);

        // Monthly attendance (unique days)
        final monthlyAttendanceDocs =
            attendanceSnapshot.docs.where((doc) => doc['userId'] == userId).toList();
        final uniqueAttendanceDays = <String>{};
        for (var doc in monthlyAttendanceDocs) {
          final timestamp = (doc['timestamp'] as Timestamp).toDate();
          final dayKey = DateFormat('yyyy-MM-dd').format(timestamp);
          uniqueAttendanceDays.add(dayKey);
        }
        final presentDays = uniqueAttendanceDays.length;

        // Calculate total eligible days (all days, no weekend exclusion)
        final totalDays = calculationEndDate.day;

        final attendancePercentage =
            totalDays > 0 ? (presentDays / totalDays * 100).toStringAsFixed(2) : "0.00";

        tempData.add({
          'userId': userId,
          'name': name,
          'status': isPresent ? 'Present' : 'Absent',
          'percentage': attendancePercentage,
          'totalDays': totalDays,
        });
      }

      setState(() {
        attendanceData = tempData;
      });
    } catch (e) {
      throw Exception('Error fetching attendance: $e');
    }
  }

  void _listenToAttendanceCounts() {
    _firestore.collection('users').snapshots().listen((snapshot) {
      final Map<String, int> counts = {};
      for (var userDoc in snapshot.docs) {
        final userData = userDoc.data();
        counts[userDoc.id] = userData['attendanceCount']?.toInt() ?? 0;
      }
      setState(() {
        attendanceCounts = counts;
      });
    }, onError: (e) {
      _showSnackBar('Error listening to attendance counts: $e');
    });
  }

  Future<void> _editAttendance(String userId) async {
    final TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Attendance Count'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Enter new count (non-negative)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final int? newCount = int.tryParse(controller.text);
              if (newCount != null && newCount >= 0) {
                try {
                  await _firestore.collection('users').doc(userId).update({
                    'attendanceCount': newCount,
                  });
                  _showSnackBar('Attendance count updated successfully');
                } catch (e) {
                  _showSnackBar('Error updating attendance count: $e');
                }
                Navigator.pop(context);
              } else {
                _showSnackBar('Please enter a valid non-negative number');
              }
            },
            child: const Text('Update'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get paginatedData {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, attendanceData.length);
    return attendanceData.sublist(startIndex, endIndex);
  }

  void _nextPage() {
    if (currentPage * itemsPerPage < attendanceData.length) {
      setState(() => currentPage++);
    }
  }

  void _previousPage() {
    if (currentPage > 1) {
      setState(() => currentPage--);
    }
  }

  void _toggleDate(bool isNextDay) {
    setState(() {
      selectedDate = isNextDay
          ? selectedDate.add(const Duration(days: 1))
          : selectedDate.subtract(const Duration(days: 1));
      currentPage = 1;
    });
    _fetchData();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        currentPage = 1;
      });
      _fetchData();
    }
  }

  Future<void> _generateAttendancePDF() async {
    final pdf = pw.Document();
    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final monthYear = DateFormat('MMMM yyyy').format(selectedDate);

    final rows = [
      pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Name', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: pw.Font.timesBold())),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: pw.Font.timesBold())),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Attendance %', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: pw.Font.timesBold())),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Text('Total Count', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: pw.Font.timesBold())),
          ),
        ],
      ),
      ...attendanceData.map((user) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(user['name'], style: pw.TextStyle(font: pw.Font.times())),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(user['status'], style: pw.TextStyle(font: pw.Font.times())),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${user['percentage']}%', style: pw.TextStyle(font: pw.Font.times())),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${attendanceCounts[user['userId']] ?? 0}', style: pw.TextStyle(font: pw.Font.times())),
              ),
            ],
          )),
    ];

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20), // Page margin
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Attendance Report - $formattedDate',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, font: pw.Font.timesBold())),
            pw.SizedBox(height: 20),
            pw.Text('Month: $monthYear', style: pw.TextStyle(fontSize: 16, font: pw.Font.times())),
            pw.SizedBox(height: 10),
            pw.Text(
              'Based on ${attendanceData.isNotEmpty ? attendanceData.first['totalDays'] : 0} days',
              style: pw.TextStyle(fontSize: 14, font: pw.Font.timesItalic()),
            ),
            pw.SizedBox(height: 30),
            pw.Table(
              border: pw.TableBorder.all(),
              columnWidths: {
                0: const pw.FlexColumnWidth(3), // Name
                1: const pw.FlexColumnWidth(2), // Status
                2: const pw.FlexColumnWidth(2), // Attendance %
                3: const pw.FlexColumnWidth(2), // Total Count
              },
              children: rows,
            ),
          ],
        ),
      ),
    );

    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/attendance_report_$formattedDate.pdf');
      await file.writeAsBytes(await pdf.save());
      await OpenFile.open(file.path);
      _showSnackBar('PDF downloaded and opened successfully');
    } catch (e) {
      _showSnackBar('Error generating PDF: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(selectedDate);
    final monthYear = DateFormat('MMMM yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Book'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            onPressed: () => _toggleDate(false),
            icon: const Icon(Icons.arrow_back_ios),
          ),
          Center(
            child: Text(
              formattedDate,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            onPressed: () => _toggleDate(true),
            icon: const Icon(Icons.arrow_forward_ios),
          ),
          IconButton(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today),
          ),
          IconButton(
            onPressed: _generateAttendancePDF,
            icon: const Icon(Icons.download),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Attendance Records - $monthYear',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Based on ${attendanceData.isNotEmpty ? attendanceData.first['totalDays'] : 0} days',
                      style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 24,
                          headingRowColor: WidgetStateColor.resolveWith(
                              (states) => Colors.deepPurple.shade100),
                          columns: const [
                            DataColumn(
                              label: Text('Name',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Status',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Attendance %',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Total Count',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            DataColumn(
                              label: Text('Action',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                          rows: paginatedData.asMap().entries.map((entry) {
                            final index = entry.key;
                            final user = entry.value;
                            return DataRow(
                              color: WidgetStateColor.resolveWith((states) =>
                                  index % 2 == 0
                                      ? Colors.grey.shade100
                                      : Colors.white),
                              cells: [
                                DataCell(Text(user['name'])),
                                DataCell(
                                  Text(
                                    user['status'],
                                    style: TextStyle(
                                      color: user['status'] == 'Present'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                                DataCell(Text('${user['percentage']}%')),
                                DataCell(Text(
                                    '${attendanceCounts[user['userId']] ?? 0}')),
                                DataCell(
                                  IconButton(
                                    icon:
                                        const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () =>
                                        _editAttendance(user['userId']),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _previousPage,
                          icon: const Icon(Icons.arrow_left),
                        ),
                        Text('$currentPage',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: _nextPage,
                          icon: const Icon(Icons.arrow_right),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
} 