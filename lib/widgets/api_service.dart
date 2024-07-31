import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:covhealth/widgets/Doctor.dart';
import'package:covhealth/widgets/config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:covhealth/widgets/const.dart';
import 'bot.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  final _model = GenerativeModel(
    model: 'gemini-1.5-flash',
    apiKey: GEMINI_API_KEY,
  );

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userToken');
  }

  //operation asynchrone avec future
  Future<List<Doctor>> fetchDoctors() async {
    try {
      //await met en pause lexecution de la fction jsqua ce que la valeure de future attendue hh.get soit resolue
      final response = await http.get(Uri.parse('${Config.backendUrl}/doctors'));
      /*print(" API response : ${response.body}");*/

      if (response.statusCode == 200) {
        List<dynamic> doctorsJson = json.decode(response.body);
        print(doctorsJson);
        //transforme en objet
        return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      throw Exception('Failed to load doctors: $e');
    }
  }
  //pour categorie
  Future<List<Doctor>> fetchDoctorsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('${Config.backendUrl}/doctors_spe?specialite=$category'));
      if (response.statusCode == 200) {
        List<dynamic> doctorsJson = json.decode(response.body);
        return doctorsJson.map((json) => Doctor.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (e) {
      throw Exception('Failed to load doctors: $e');
    }
  }
  //verifier heure doc avant reservation
  Future<Map<String, dynamic>> getDoctorWorkHours(String doctorId) async {
    try {
      /*User? user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();*/
      String? token = await getToken();
      if (token == null) throw Exception('Utilisateur non authentifié');




      var response = await http.get(
        Uri.parse('${Config.backendUrl}/doctors/$doctorId/workhours'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Echec du chargement des heures de travail');
      }
    } catch (e) {
      rethrow;
    }
  }

  //reserver un rendezVous
  Future<http.Response> bookAppointment(String doctorId, DateTime date, String? timeSlot, String nom, String prenom) async {
    try {
      /*User? user = FirebaseAuth.instance.currentUser;
      String? token = await user?.getIdToken();*/
      String? token = await getToken();
      print('recption du tokennnn ${token}');
      if (token == null) throw Exception('Utilisateur non authentifié');


      var response = await http.post(
        Uri.parse('${Config.backendUrl}/rendezvous'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'doctorId': doctorId,
          'date': DateFormat('yyyy-MM-dd').format(date),
          'timeSlot': timeSlot,
          'nom': nom,
          'prenom':prenom,
        }),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  //recuperer la liste de rendezvous d'un patient
  Future<Map<String, List<dynamic>>> fetchAppointments(String userId) async {

    String? token = await getToken();
    if (token == null) throw Exception('Utilisateur non authentifié');

    final response = await http.get(
      Uri.parse('${Config.backendUrl}/user/$userId/rendezvous'),
      headers: {
        'Content-Type': 'application/json',
        //'Authorization': 'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}',
        'Authorization': 'Bearer $token',

      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      print("Données reçues : $data");
      return {
        'upcoming': data['upcoming_appointments'],
        'past': data['past_appointments'],
        'canceled_by_patient': data['canceled_by_patient'],
      };
    } else {
      throw Exception('Échec du chargement des rendezvous');
    }
  }

  //annuler rendezvous
  Future<Map<String, dynamic>> cancelAppointment(String appointmentId, String comment, String userId) async {
    String? token = await getToken();
    if (token == null) throw Exception('Utilisateur non authentifié');

    final response = await http.post(
      Uri.parse('${Config.backendUrl}/cancelAppointment'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'appointmentId': appointmentId,
        'comment': comment,
        'userId': userId,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to cancel appointment: ${response.statusCode}');
    }
  }

//pour ajouter un journal de sante
  Future<void> addEntry(String token, String entry, String appointmentId) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }
    print("Token: $token");
    print("Entry: $entry");
    final response = await http.post(
      Uri.parse('${Config.backendUrl}/ajouter_journal'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'entry': entry,
        'appointment_id': appointmentId,}),
    );
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode != 200) {
      throw Exception('Failed to add entry');
    }
  }
  //pour recuperer les consul
  Future<List<dynamic>> fetchConsultations(String userId) async {
    String? token = await getToken();
    if (token == null) throw Exception('Utilisateur non authentifié');

    final response = await http.get(
      Uri.parse('${Config.backendUrl}/consultations/$userId'),
      headers: {
        'Content-Type': 'application/json',
        //'Authorization': 'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}',
        'Authorization': 'Bearer $token',

      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      print("Données reçues : $data");
      return data;
    } else {
      throw Exception('Echec du chargement des consultations');
    }
  }

  //pour stocker fcm dans ma BD
  static Future<void> updateFcmToken(String userId, String fcmToken) async {
    final response = await http.post(
      Uri.parse('${Config.backendUrl}/update_fcm_token'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'user_id': userId,
        'fcm_token': fcmToken,
      }),
    );

    if (response.statusCode == 200) {
      print('FCM token updated successfully');
    } else {
      print('Failed to update FCM token');
    }
  }




//Pour communiquer avec gemini
  Future<String> getMedicalResponse(String query) async {
    final prompt = 'vous êtes assistant médicale; Fournissez des informations médicales et conseils. Ne répondez qu\'à des questions d\'ordre médical.: $query';
    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);

    if (response != null && response.text != null && response.text!.isNotEmpty) {
      return response.text!;
    } else {
      throw Exception('Failed to get response');
    }
  }

  //tout ce qui concerne historique des message avec le bot
  /*Future<String?> getToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null ? await user.getIdToken() : null;
  }*/

  Future<List<Conversation>> getConversations() async {
    String? token = await getToken();
    if (token == null) throw Exception('Utilisateur non authentifié');


    final response = await http.get(
      Uri.parse('${Config.backendUrl}/conversations'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',

      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      print("Received conversations: $data"); // Ajoutez ce journal

      return data.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<Conversation> getConversation(String conversationId) async {
    String? token = await getToken();
    if (token == null) throw Exception('Utilisateur non authentifié');

    print('Récupération de la conversation avec ID: $conversationId'); // Debug print


    final response = await http.get(
      Uri.parse('${Config.backendUrl}/conversation/$conversationId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print('Code de statut de la réponse: ${response.statusCode}');
    print('Réponse de l\'API: ${response.body}');

    if (response.statusCode == 200) {
      print('Réponse de la conversation: ${response.body}');

      return Conversation.fromJson(json.decode(response.body));
    } else {
      print('Échec du chargement de la conversation, réponse: ${response.body}');

      throw Exception('Failed to load conversation');
    }
  }

  Future<void> sendMessage(String conversationId, ChatBubbleData message) async {
    /*String? token = await getToken();
    if (token == null) {
      throw Exception('User not authenticated');
    }*/
    String? token = await getToken();
    if (token == null) throw Exception('Utilisateur non authentifié');


    final response = await http.post(
      Uri.parse('${Config.backendUrl}/conversation'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'conversation_id': conversationId,
        'message': message.toJson(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to send message');
    }
  }

  Future<String> createConversation(String title, List<String> participants) async {
    /*User? user = FirebaseAuth.instance.currentUser;
    String? token = await user?.getIdToken();*/
    String? token = await getToken();
    if (token == null) throw Exception('Utilisateur non authentifié');


    final response = await http.post(
      Uri.parse('${Config.backendUrl}/conversation_create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'participants': participants,
      }),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['conversation_id'];
    } else {
      throw Exception('Failed to create conversation');
    }
  }








}