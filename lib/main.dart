import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Model untuk absensi
class Attendance {
  final String id;
  final String name;
  final DateTime date;

  Attendance({
    required this.id,
    required this.name,
    required this.date,
  });
}

// Provider untuk manajemen absensi
class AttendanceProvider with ChangeNotifier {
  List<Attendance> _attendances = [];

  List<Attendance> get attendances => _attendances;

  void addAttendance(String name) {
    _attendances.add(
      Attendance(
        id: DateTime.now().toString(),
        name: name,
        date: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void removeAttendance(String id) {
    _attendances.removeWhere((attendance) => attendance.id == id);
    notifyListeners();
  }
}

// Layar Absensi
class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _addAttendance() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      Provider.of<AttendanceProvider>(context, listen: false).addAttendance(name);
      _nameController.clear();
    }
  }

  void _refreshAttendance() {
    setState(() {});
  }

  void _deleteAttendance(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Hapus Absensi'),
        content: Text('Apakah Anda yakin ingin menghapus absensi ini?'),
        actions: <Widget>[
          TextButton(
            child: Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text('Hapus'),
            onPressed: () {
              Provider.of<AttendanceProvider>(context, listen: false).removeAttendance(id);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Absensi'),
        backgroundColor: Colors.teal,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshAttendance,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Masukkan Nama',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Harap masukkan nama';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addAttendance,
                  child: Text('Catat Absensi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Menggunakan backgroundColor bukan primary
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nama')),
                DataColumn(label: Text('Tanggal')),
                DataColumn(label: Text('Aksi')),
              ],
              rows: attendanceProvider.attendances.map((attendance) {
                return DataRow(
                  cells: [
                    DataCell(Text(attendance.name)),
                    DataCell(Text('${attendance.date.toLocal()}')),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAttendance(attendance.id),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 60,
          color: Colors.teal[50],
          child: Center(
            child: Text(
              'Aplikasi Absensi',
              style: TextStyle(fontSize: 16, color: Colors.teal[900]),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => AttendanceProvider(),
      child: MaterialApp(
        title: 'Aplikasi Absensi',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(),
          ),
        ),
        home: AttendanceScreen(),
      ),
    );
  }
}
