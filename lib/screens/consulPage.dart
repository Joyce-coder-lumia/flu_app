import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:covhealth/widgets/UserService.dart';
import 'package:covhealth/widgets/api_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:android_path_provider/android_path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';




class ConsulPage extends StatefulWidget {
  const ConsulPage({super.key});

  @override
  State<ConsulPage> createState() => _ConsulPageState();
}

class _ConsulPageState extends State<ConsulPage> {
  late Future<List<dynamic>> _consultations;

  @override
  void initState() {
    super.initState();
    _consultations = fetchConsultations();
  }

  Future<List<dynamic>> fetchConsultations() async {
    final currentUser = Provider.of<UserService>(context, listen: false).currentUser;
    String userId;

    if (currentUser == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
      print('User ID from SharedPreferences: $userId');

      if (userId.isEmpty) {
        throw Exception('Utilisateur non identifié');
      }
    } else {
      userId = currentUser.uid;
    }
    //return await ApiService().fetchConsultations(currentUser.uid);
    return await ApiService().fetchConsultations(userId);

  }

  void _showConsultationDetails(BuildContext context, dynamic consultation) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          title: Text('Consultation Details'),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Diagnostic
                  Text(
                    'Diagnostics:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                  ),
                  SizedBox(height: 4), 
                  Text(consultation['diagnostics']),
                  SizedBox(height: 16), 

                  // Prescriptions
                  Text(
                    'Prescriptions:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                  ),
                  SizedBox(height: 4), 
                  Text(consultation['prescriptions']),
                  SizedBox(height: 16), 

                  // Advice
                  Text(
                    'Advice:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                  ),
                  SizedBox(height: 4), 
                  Text(consultation['advice']),
                  SizedBox(height: 16), 

                  // Additional Notes
                  Text(
                    'Additional Notes:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                  ),
                  SizedBox(height: 4), 
                  Text(consultation['additional_notes']),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.download),
              onPressed: () {
                _downloadConsultation(consultation);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }





  Future<void> _downloadConsultation(dynamic consultation) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Diagnostics:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue),
              ),
              pw.Text(
                consultation['diagnostics'],
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Prescriptions:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue),
              ),
              pw.Text(
                consultation['prescriptions'],
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Advice:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue),
              ),
              pw.Text(
                consultation['advice'],
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Additional Notes:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColors.blue),
              ),
              pw.Text(
                consultation['additional_notes'],
                style: pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );

    final String downloadsPath = (await AndroidPathProvider.downloadsPath)!;
    final String covhealthDirPath = "$downloadsPath/COVHEALTH";
    final Directory covhealthDir = Directory(covhealthDirPath);

    if (!await covhealthDir.exists()) {
      await covhealthDir.create(recursive: true);
    }

    final String filePath = "$covhealthDirPath/consultation_${consultation['_id']}.pdf";
    final File file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Consultation téléchargée avec succès: $filePath')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFAA9DFA),
        title: Text('Consultations'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _consultations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No consultations found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var consultation = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15.0),
                      title: Text(
                        'Consultation',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            consultation['diagnostics'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10),
                          Text(
                            consultation['prescriptions'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      onTap: () => _showConsultationDetails(context, consultation),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
