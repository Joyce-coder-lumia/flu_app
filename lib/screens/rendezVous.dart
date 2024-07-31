import 'package:flutter/material.dart';
import 'package:covhealth/widgets/Doctor.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:covhealth/widgets/api_service.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:covhealth/widgets/UserService.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'listeRendezVous.dart';

class RendezVous extends StatefulWidget {
  final Doctor doctor;

  const RendezVous({Key? key, required this.doctor}) : super(key: key);
  @override
  State<RendezVous> createState() => _RendezVousState();
}

class _RendezVousState extends State<RendezVous> {
  DateTime selectedDate = DateTime.now();
  String? selectedTimeSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prenez rendez-vous", style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFFE0A3F8).withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: selectedDate,
                calendarFormat: CalendarFormat.month,
                selectedDayPredicate: (day) => isSameDay(selectedDate, day),

                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    selectedDate = selectedDay;
                  });
                },
              ),
            ),
            SizedBox(height: 18),
            timeSlotWidget(),
          ],
        ),
      ),
    );
  }

  //plage horaire
  Widget timeSlotWidget() {
    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: List<Widget>.generate(13, (int index) {
            return Container(
              margin: EdgeInsets.all(1),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 12,
                    offset: Offset(1, 12),
                  ),
                ],
              ),
              child: ChoiceChip(
                label: Text('${index + 7}:00 - ${index + 8}:00'),
                selected: selectedTimeSlot == '${index + 7}:00 - ${index + 8}:00',
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) selectedTimeSlot = '${index + 7}:00 - ${index + 8}:00';
                  });
                },
                backgroundColor: Colors.white,
                selectedColor: Color(0xFF3214EA).withOpacity(0.5),
                labelStyle: TextStyle(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: BorderSide(color: Colors.transparent),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 18),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: InkWell(
          onTap: () {
            bookAppointment();
          },
          child: Container(
            width: double.infinity,
            height: 50.0,
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [Color(0xFFCD4FFF), Color(0xCC3214E9)],
              ),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Center(
              child: Text(
                'Réservez',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
              ),
            ),
          ),
        ),
        ),
      ],
    );
  }

  void bookAppointment() async {
    final currentUser = Provider.of<UserService>(context, listen: false).currentUser;

    String userId;
    String userNom;
    String userPrenom;

    if (currentUser == null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      userId = prefs.getString('userId') ?? '';
      userNom = prefs.getString('userNom') ?? '';
      userPrenom = prefs.getString('userPrenom') ?? '';

      // Impressions de débogage
      print("userId from SharedPreferences: $userId");
      print("userNom from SharedPreferences: $userNom");
      print("userPrenom from SharedPreferences: $userPrenom");

      if (userId== null || userNom== null || userPrenom== null) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: 'Utilisateur non identifié',
          desc: 'Veuillez vous connecter à nouveau.',
          btnOkOnPress: () {},
        )..show();
        return;
      }
    } else {
      userId = currentUser.uid;
      userNom = currentUser.nom;
      userPrenom = currentUser.prenom;

      // Impressions de débogage
      print("currentUser uid: $userId");
      print("currentUser nom: $userNom");
      print("currentUser prenom: $userPrenom");
    }

    print("Selected Time Slot before booking: $selectedTimeSlot");

    if (selectedTimeSlot == null ) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Créneau horaire manquant',
        desc: 'Veuillez sélectionner un créneau horaire avant de réserver.',
        btnOkOnPress: () {},
      )..show();
      return;
    }

    // Récupérez les heures de travail du médecin
    Map<String, dynamic> workHours = await ApiService().getDoctorWorkHours(widget.doctor.id);
    String workStart = workHours['heuresDebut']!;
    String workEnd = workHours['heuresFin']!;
    List<dynamic> joursTravail = workHours['joursTravail'] as List<dynamic>;

    print("Work Start: $workStart, Work End: $workEnd");
    print("Jours Travail: $joursTravail");

    if (joursTravail.isEmpty) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.bottomSlide,
        title: 'Erreur',
        desc: 'Les jours de travail du médecin ne sont pas disponibles.',
        btnOkOnPress: () {},
      )..show();
      return;
    }

    // Formatage de la date et du créneau horaire
    String formattedTimeSlot = selectedTimeSlot!;

    String startTime = formattedTimeSlot.split('-')[0].trim();
    String endTime = formattedTimeSlot.split('-')[1].trim();

    // Vérification des heures de travail du docteur avant d'envoyer la requête
    TimeOfDay workStartTime = TimeOfDay(hour: int.parse(workStart.split(':')[0]), minute: int.parse(workStart.split(':')[1]));
    TimeOfDay workEndTime = TimeOfDay(hour: int.parse(workEnd.split(':')[0]), minute: int.parse(workEnd.split(':')[1]));
    TimeOfDay selectedStartTime = TimeOfDay(hour: int.parse(startTime.split(':')[0]), minute: int.parse(startTime.split(':')[1]));
    TimeOfDay selectedEndTime = TimeOfDay(hour: int.parse(endTime.split(':')[0]), minute: int.parse(endTime.split(':')[1]));


    if (selectedStartTime.hour < workStartTime.hour || selectedEndTime.hour > workEndTime.hour) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Créneau horaire non valide',
        desc: 'Le créneau horaire choisi est en dehors des heures de travail du médecin.',
        btnOkOnPress: () {},
      )..show();
      return;
    }

    int selectedWeekday = selectedDate.weekday - 1;
    print("Selected Weekday: $selectedWeekday, Works on this day: ${joursTravail[selectedWeekday]}");

    if (joursTravail.isNotEmpty && joursTravail[selectedWeekday] == false) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.bottomSlide,
        title: 'Jour non valide',
        desc: 'Le médecin ne travaille pas ce jour-là.',
        btnOkOnPress: () {},
      )..show();
      return;
    }

    //var response = await ApiService().bookAppointment(widget.doctor.id, selectedDate, formattedTimeSlot,userNom, userPrenom /*currentUser.nom, currentUser.prenom*/);
     ApiService().bookAppointment(widget.doctor.id, selectedDate, formattedTimeSlot,userNom, userPrenom ).then((response) =>
    {if (response.statusCode == 201) {
      AwesomeDialog(
      context: context,
      animType: AnimType.bottomSlide,
      dialogType: DialogType.success,
      showCloseIcon: true,
      title: 'Succès',
      desc: 'Rendez-vous réservé avec succès.',
      btnOkOnPress: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListeRendezVous()),
        );
      },
    )..show(),
  } else {
    AwesomeDialog(
    context: context,
    animType: AnimType.bottomSlide,
    dialogType: DialogType.error,
    showCloseIcon: true,
    title: 'Erreur',
    desc: 'Erreur lors de la réservation du rendez-vous: ${response.body}',
    btnOkOnPress: () {},
    )..show(),
    }
    });




  }
}
