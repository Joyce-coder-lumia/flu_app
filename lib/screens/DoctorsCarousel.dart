import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:covhealth/widgets/Doctor.dart';
import 'package:covhealth/widgets/api_service.dart';


class DoctorsCarousel extends StatefulWidget {
  @override
  _DoctorsCarouselState createState() => _DoctorsCarouselState();
}

class _DoctorsCarouselState extends State<DoctorsCarousel> {
  late Future<List<Doctor>> futureDoctors;
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  void initState() {
    super.initState();
    futureDoctors = ApiService().fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Doctor>>(
      future: futureDoctors,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        } else if (snapshot.hasData) {
          var doctorsToShow = snapshot.data!.take(3).toList();

          return Column(
            children: [
              CarouselSlider(
                items: snapshot.data!.map((doctor) => buildDoctorCard(doctor)).toList(),
                options: CarouselOptions(
                  autoPlay: true,
                  aspectRatio: 2.0,
                  enlargeCenterPage: true,
                  pageSnapping: true,
                  viewportFraction: 0.8,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: doctorsToShow.asMap().entries.map((entry) {
                  return GestureDetector(
                    onTap: () => _controller.animateToPage(entry.key),
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black).withOpacity(_current == entry.key ? 0.9 : 0.4),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        } else {
          return Text("No doctors found");
        }
      },
    );
  }

  Widget buildDoctorCard(Doctor doctor) {
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(0xFFE0A3F8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 5,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dr \n${doctor.name}',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  doctor.specialty,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          /*SizedBox(width: 5),*/
          /*CircleAvatar(
            radius: 48,
            backgroundImage: NetworkImage(doctor.imageUrl),
            backgroundColor: Colors.transparent,
          ),*/
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.contain,
                image: NetworkImage(doctor.imageUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}