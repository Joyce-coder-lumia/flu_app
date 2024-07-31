import 'package:flutter/material.dart';
import 'package:covhealth/widgets/Doctor.dart';
import 'package:covhealth/screens/rendezVous.dart';

class DescriptionDoctor extends StatelessWidget {
  final Doctor doctor;

  const DescriptionDoctor({Key? key, required this.doctor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD062FA),
      body: SafeArea(
        child: Column(
          children: [
          Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white,),
              onPressed: () => Navigator.pop(context),
            ),
          ),
            /*Image.asset(
              'assets/images/docdoc.png',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
            ),*/
            Image.network(
                doctor.imageUrl,
                width: double.infinity,
                height: 300,
                //fit: BoxFit.cover,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Dr ${doctor.name}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                      Text('${doctor.specialty} Spécialiste', style: TextStyle(fontSize: 18, color: Colors.black54)),
                      SizedBox(height: 20),
                      Text('Heures de travail', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(doctor.workingTime, style: TextStyle(fontSize: 16)),
                      SizedBox(height: 20),
                      Text('A propos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text(
                        doctor.description,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => RendezVous(doctor:doctor),),
                          );
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
                              'Réservez sur rendez-vous',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}

