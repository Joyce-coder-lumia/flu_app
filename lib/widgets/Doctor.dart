class Doctor {
  final String id;
  final String name;
  final String imageUrl;
  final String specialty;
  final String description;
  final String workingTime;

  Doctor({required this.id, required this.name, required this.imageUrl, required this.specialty, required this.description, required this.workingTime});

  static String formatWorkingDays(List<dynamic> days) {
    if (days.every((day) => day == false)) {
      return "Aucun jour de travail";
    }
    List<String> dayNames = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi", "Dimanche"];
    List<String> workingDays = [];
    for (int i = 0; i < days.length; i++) {
      if (days[i] == true) {
        workingDays.add(dayNames[i]);
      }
    }
    return workingDays.join(', ');
  }
  // retourner une instance de la classe
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id']['\$oid']??"inconnu",
      name: "${json['nom']} ${json['prenom']}",
      imageUrl: json['profileImageUrl'] ?? 'default_image_url',
      specialty: json['specialite']?? 'Spécialité Inconnue',
      description: json['description'],
      workingTime: formatWorkingDays(json['joursTravail']) + " " + json['heuresDebut'] + " - " + json['heuresFin']
    );
  }
}
