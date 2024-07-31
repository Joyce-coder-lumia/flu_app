import 'package:flutter/material.dart';
import 'package:covhealth/widgets/api_service.dart';
import 'package:covhealth/widgets/UserService.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'rendezVous.dart';
import 'package:covhealth/widgets/Doctor.dart';

class ListeRendezVous extends StatefulWidget {
  const ListeRendezVous({Key? key}) : super(key: key);

  @override
  State<ListeRendezVous> createState() => _ListeRendezVousState();
}

class _ListeRendezVousState extends State<ListeRendezVous> {
  String? _token;
  late Future<Map<String, List<dynamic>>> _appointments;
  TextEditingController _journalController = TextEditingController();




  @override
  void initState() {
    super.initState();
    _appointments = fetchAppointments();
    _getToken();



  }

  /*Future<void> _getToken() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _token = await user.getIdToken();
        print("Token recu: $_token");
      } else {
        print("User is not signed in");
      }
    } catch (e) {
      print("Error retrieving token: $e");
    }
  }*/
  Future<void> _getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('userToken');
      if (_token != null) {
        print("Token recu: $_token");
      } else {
        print("Token non trouvé");
      }
    } catch (e) {
      print("Error retrieving token: $e");
    }
  }

  Future<Map<String, List<dynamic>>> fetchAppointments() async {
    final currentUser = Provider.of<UserService>(context, listen: false).currentUser;
    print('Utilisateur actuel unnnn listerendezvous: $currentUser');

    /*if (currentUser == null) {
      throw Exception('Utilisateur non identifié');
    }*/
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

    /*print('Utilisateur authentifié unnnnndeuxxx, UID: ${currentUser.uid}');
    return await ApiService().fetchAppointments(currentUser.uid);*/
    print('Utilisateur authentifié unnnnndeuxxx, UID: $userId');
    return await ApiService().fetchAppointments(userId);
  }


  Future<void> cancelAppointment(String appointmentId, String comment) async {
    final currentUser = Provider.of<UserService>(context, listen: false).currentUser;
    /*if (currentUser == null) {
      throw Exception('Utilisateur non identifié');
    }*/
    String userId;

    if (currentUser == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        throw Exception('Utilisateur non identifié');
      }
    } else {
      userId = currentUser.uid;
    }

    try {
      print('Attempting joyce: $appointmentId');

      //final response = await ApiService().cancelAppointment(appointmentId, comment, currentUser.uid);
      final response = await ApiService().cancelAppointment(appointmentId, comment, userId);

      print('API response: $response');

      if (response['message'] == 'Rendez-vous annulé avec succès') {
        print('moi lumia je connais que LUMIA');
        setState(() {
          _appointments = fetchAppointments();

        });
      } else {
        throw Exception(response['message']);
      }
    } catch (e) {
      print('Error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'annulation du rendez-vous: $e')),
      );
    }
  }

  Future<void> _submitJournalEntry(String appointmentId) async {
    final currentUser = Provider.of<UserService>(context, listen: false).currentUser;
    /*if (currentUser == null) {
      throw Exception('Utilisateur non identifié');
    }*/
    String userId;

    if (currentUser == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        throw Exception('Utilisateur non identifié');
      }
    } else {
      userId = currentUser.uid;
    }

    print("Token joyjoy: $_token");
    print("Journal entry joyjoy: ${_journalController.text}");

    if (_token != null && _journalController.text.isNotEmpty) {
      try {
        await ApiService().addEntry(_token!, _journalController.text, appointmentId);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Entrée de journal ajoutée avec succès')));
        _journalController.clear();
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Échec de l\'ajout de l\'entrée de journal')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez écrire quelque chose dans le journal')));
    }
  }

  void _showCancelDialog(String appointmentId) {
    TextEditingController commentController = TextEditingController();
    print('Opening cancel dialog for Appointment ID: $appointmentId');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Annuler le rendez-vous'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: "Entrez un commentaire"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirmer'),
              onPressed: () {
                if (commentController.text.isNotEmpty) {
                  print('Confirmed cancellation for Appointment ID: $appointmentId');
                  cancelAppointment(appointmentId, commentController.text);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez entrer un commentaire')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showJournalDialog(String appointmentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une entrée de journal'),
          content: TextField(
            controller: _journalController,
            maxLines: 5,
            decoration: InputDecoration(hintText: "Écrire dans le journal de santé..."),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Soumettre'),
              onPressed: () {
                if (_journalController.text.isNotEmpty) {
                  _submitJournalEntry(appointmentId);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Veuillez écrire quelque chose dans le journal')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFAA9DFA),
          title: Text("Mes Rendez-vous"),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'A venir'),
              Tab(text: 'Passé'),
              Tab(text: 'Annulé'),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, List<dynamic>>>(
          future: _appointments,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Aucun rendez-vous trouvé'));
            } else {
              var upcomingAppointments = snapshot.data!['upcoming']!;
              var pastAppointments = snapshot.data!['past']!;
              var canceledByPatientAppointments = snapshot.data!['canceled_by_patient']!;
              print("Upcoming Appointments: $upcomingAppointments"); // Ligne de débogage
              print("Past Appointments: $pastAppointments"); // Ligne de débogage
              print("Canceled by Patient Appointments: $canceledByPatientAppointments"); // Ligne de débogage

              return TabBarView(
                children: [
                  AppointmentList(appointments: upcomingAppointments, showCancelButton: true, onCancel: _showCancelDialog, onAddJournal: _showJournalDialog),
                  AppointmentList(appointments: pastAppointments, showCancelButton: false, onCancel: null, onAddJournal: _showJournalDialog),
                  AppointmentList(appointments: canceledByPatientAppointments, showCancelButton: false, onCancel: null, onAddJournal: null),
                ],
              );
            }
          },
        ),
      ),



    );
  }
}

class AppointmentList extends StatelessWidget {
  final List<dynamic> appointments;
  final bool showCancelButton;
  final Function(String)? onCancel;
  final Function(String)? onAddJournal;

  const AppointmentList({Key? key, required this.appointments, required this.showCancelButton, this.onCancel, required this.onAddJournal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        var appointment = appointments[index];
        String appointmentId = appointment['_id']?.toString() ?? '';
        return AppointmentCard(
          appointment: appointment,
          showCancelButton: showCancelButton,
          onCancel: onCancel != null ? () => onCancel!(appointmentId) : null,
          onAddJournal: onAddJournal != null ? () => onAddJournal!(appointmentId) : null, // Modification ici
        );
      },
    );
  }
}



class AppointmentCard extends StatelessWidget {
  final dynamic appointment;
  final bool showCancelButton;
  final VoidCallback? onCancel;
  final VoidCallback? onAddJournal;


  const AppointmentCard({Key? key, required this.appointment, required this.showCancelButton, this.onCancel, required this.onAddJournal}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // permettre l'affichage de date en un bon format
    final dateParts = appointment['date'].split('-');
    final day = dateParts[2];
    final month = _getMonthName(int.parse(dateParts[1]));

    return GestureDetector(
      onTap: onAddJournal,

      child: Container(

        margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 5,
              offset: Offset(1, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(27),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    day,
                    style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    month,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr ${appointment['doctorName']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${appointment['specialty']} spécialiste',
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16),
                      SizedBox(width: 5),
                      Text(appointment['time']),
                      Spacer(),

                      if (showCancelButton)
                        ElevatedButton(
                          onPressed: onCancel,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFE0A3F8),
                          ),
                          child: Text(
                            'Annuler',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),



                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int monthNumber) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[monthNumber - 1];
  }
}
