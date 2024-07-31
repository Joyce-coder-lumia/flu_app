class UserModel {
  final String uid;
  final String email;
  final String nom;
  final String prenom;
  final String phoneNumber;
  final String role;
  final String? profileImage;


  UserModel({
    required this.uid,
    required this.email,
    required this.nom,
    required this.prenom,
    required this.phoneNumber,
    required this.role,

    this.profileImage,

  });

}