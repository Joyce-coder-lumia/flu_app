import 'package:covhealth/screens/descriptionDoctor.dart';
import 'package:flutter/material.dart';
import 'package:covhealth/widgets/api_service.dart';
import 'package:covhealth/widgets/Doctor.dart';

class CategoryDoctors extends StatefulWidget {
  final String searchQuery;

  const CategoryDoctors({required this.searchQuery, super.key});

  @override
  State<CategoryDoctors> createState() => _CategoryDoctorsState();
}

class _CategoryDoctorsState extends State<CategoryDoctors> {
  List<Map<String, dynamic>> categories = [
    {"name": "Coeur", "image": "assets/images/heart.jpg"},
    {"name": "Oeil", "image": "assets/images/eyes.png"},
    {"name": "Cerveau", "image": "assets/images/brain.png"},
    {"name": "Poumon", "image": "assets/images/lung.jpg"}
  ];

  String selectedCategory = "Coeur";
  List<Doctor> doctors = [];
  List<Doctor> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    fetchDoctorsByCategory(selectedCategory);
  }

  @override
  void didUpdateWidget(CategoryDoctors oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery) {
      _filterDoctors();
    }
  }

  void fetchDoctorsByCategory(String category) async {
    try {
      List<Doctor> result = await ApiService().fetchDoctorsByCategory(category);
      print('Doctors fetched for category $category: ${result.length}');

      setState(() {
        doctors = result;
        _filterDoctors();

        print('Updated doctors list length: ${doctors.length}');

      });
    } catch (e) {
      print('Failed to load doctors: $e');
      setState(() {
        doctors = [];
        filteredDoctors = [];
      });
    }
  }

  void _filterDoctors() {
    String query = widget.searchQuery.toLowerCase();
    print('Filtering doctors with query: $query');

    setState(() {
      if (query.isEmpty) {
        filteredDoctors = doctors;
      } else {
        filteredDoctors = doctors.where((doctor) {
          bool matches = doctor.name.toLowerCase().contains(query);
          print('Doctor ${doctor.name} matches: $matches');
          return matches;
        }).toList();
      }
      print('Filtered doctors count: ${filteredDoctors.length}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Catégories', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = categories[index]['name'];
                      fetchDoctorsByCategory(selectedCategory);
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(categories[index]['image'], width: 86, height: 54),
                        SizedBox(height: 8),
                        Text(categories[index]['name'])
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Docteurs disponibles', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: filteredDoctors.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  buildDoctorLst(filteredDoctors[index]),
                  SizedBox(height: 10),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildDoctorLst(Doctor doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => DescriptionDoctor(doctor:doctor),
        ));
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric( horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(doctor.imageUrl),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr ${doctor.name}', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('${doctor.specialty} Spécialiste', style: TextStyle(color: Colors.grey[700])),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}
