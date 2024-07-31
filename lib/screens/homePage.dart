import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:covhealth/screens/DoctorsCarousel.dart';
import 'package:covhealth/screens/categoryDoctors.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'chatPage.dart';
import 'loginPage.dart';
import 'package:covhealth/screens/listeRendezVous.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:covhealth/screens/notiifcationScreen.dart';
import 'package:covhealth/screens/messageScreen.dart';
import 'package:covhealth/widgets/notificationService.dart';
import 'historiquePage.dart';
import 'package:provider/provider.dart';
import 'package:covhealth/widgets/firebase_auth_services.dart';
import 'package:covhealth/widgets/api_service.dart';
import 'faqPage.dart';
import 'consulPage.dart';
import 'package:covhealth/widgets/UserService.dart';
import 'package:covhealth/widgets/userModel.dart';
import 'package:firebase_auth/firebase_auth.dart';





class HomePage extends StatefulWidget {
  final String? userToken;

  const HomePage({Key? key, this.userToken}) : super(key: key);

  //const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FirebaseMessaging _firebaseMessaging;
  String? _token;
  List<RemoteMessage> messages = [];
  List<Widget> _pages = [];
  int _currentIndex = 0;
  int _unreadMessagesCount = 0;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final ApiService _apiService = ApiService();







  @override
  void initState() {
    print("joyce appele");

    super.initState();
    _firebaseMessaging = FirebaseMessaging.instance;

    _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground! joyyyyyy');
      print('Message data joyyyyyyyyyy: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        NotificationService.showLocalNotification(
          message.notification!.title ?? 'No Title',
          message.notification!.body ?? 'No Body',
          'payload',
        );

      }
      setState(() {
        messages.add(message);
        _unreadMessagesCount++;
        print('_unreadMessagesCount joyyyyevaaaa: $_unreadMessagesCount');



      });
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MessageScreen(message: message)),
      );
    });

    _registerFcmToken();



  }
  // Enregistre le jeton FCM pour l'utilisateur actuel et l'affiche pour le débogage.
  Future<void> _registerFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      setState(() {
        _token = token;
      });
      if (token != null) {
        print("FCM Token: $token");
        /*ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("FCM Token: $token"))
        );*/
      } else {
        print("Failed to get FCM token.");
      }
    } catch (e) {
      print("Error getting FCM token: $e");
    }
  }

  Future<void> _startNewConversation() async {
    try {
      final conversationId = await _apiService.createConversation('New Conversation', ['participant1', 'participant2']);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            conversationId: conversationId,

          ),
        ),
      );
    } catch (e) {
      print("Error starting new conversation: $e");
    }
  }












  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserService>(context).currentUser;


    _pages.add(_buildReservation());
    _pages.add(_buildNewChat());
    _pages.add(_buildRendezVous());
    return WillPopScope(
        onWillPop: () async {
          // Intercepter le bouton retour pour éviter la redirection vers la page de connexion
          if (_currentIndex == 0) {
            // Quitter l'application si l'utilisateur est déjà sur la page d'accueil
            return true;
          } else {
            // Sinon, revenir à la page précédente
            setState(() {
              _currentIndex = 0;
            });
            return false;
          }
        },

    child:  Scaffold(
      backgroundColor: Colors.white,
      drawer: _buildMenu(currentUser),

      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Color(0xFFE0A3F8),
        animationDuration: Duration(milliseconds: 300),
        onTap: (index){
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          Icon(Icons.home, size: 30,),
          Icon(MdiIcons.chatProcessingOutline, size: 30,),
          Icon(Icons.note_alt)
        ],),
    ),


    );
  }
  Widget _buildReservation() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 18.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(
                  builder: (context) {
                    return IconButton(
                      icon: Icon(Icons.menu, size: 33, color: Colors.black),
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                    );
                  },
                ),
                Stack(
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications, size: 33, color: Colors.black),
                      onPressed: () {
                        setState(() {
                          _unreadMessagesCount = 0;
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NotificationsScreen(messages: messages)),
                        );
                      },
                    ),
                    if (_unreadMessagesCount > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Center(
                            child: Text(
                              '$_unreadMessagesCount',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un docteur...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          SizedBox(height: 16.0),
          DoctorsCarousel(),
          CategoryDoctors(searchQuery: _searchQuery),
          SizedBox(height: 20.0),
        ],
      ),
    );
  }

  Widget _buildNewChat(){
    return Stack(
      children: [
        // Image centrée
        Center(
          child: Image.asset(
            'assets/images/log.png',
            fit: BoxFit.contain,
          ),
        ),
        // Bouton "Nouvelle discussion" en haut
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
            child: OutlinedButton(
              onPressed: _startNewConversation, // Appel de la nouvelle méthode ici

              /*onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage()),);
              },*/
              style: OutlinedButton.styleFrom(
                foregroundColor: Color(0xFF000000),
                side: BorderSide(color: Color(0xFFD062FA), width: 2.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Nouvelle discussion', style: TextStyle(fontSize: 20),),
                  Icon(Icons.add, color:  Color(0xFF000000),),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRendezVous() {
    return ListeRendezVous();
  }

    Drawer _buildMenu(UserModel? currentUser) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFFE8C4F6),
            ),
            accountName: Text('${currentUser?.nom ?? ''} ${currentUser?.prenom ?? ''}'),
            accountEmail: Text(''),

            currentAccountPicture: CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage('assets/images/profile.jpg'),
            ),
          ),
          SizedBox(height: 0.40,),
          ListTile(
            leading: Icon(Icons.history, color: Colors.black,),
            title: const Text('Historique des conversations'),
            hoverColor: Color(0xFFE8C4F6),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => HistoriquePage()));
            },
          ),
          SizedBox(height: 2.0,),
          Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),

          ListTile(
            leading: Icon(Icons.help, color: Colors.black,),
            title: const Text('FAQ Covhealth'),
            hoverColor: Color(0xFFE8C4F6),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => FAQPage()));

            },
          ),
          SizedBox(height: 2.0,),
          Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),
          

          ListTile(
            leading: Icon(Icons.book, color: Colors.black,),
            title: const Text('Mes consultations'),
            hoverColor: Color(0xFFE8C4F6),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ConsulPage()));
            },
          ),
          SizedBox(height: 2.0,),
          Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),





          ListTile(
            leading: Icon(Icons.settings, color: Colors.black,),
            title: const Text('Setting'),
            hoverColor: Color(0xFFE8C4F6),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 2.0,),
          Divider(
            color: Colors.grey,
            thickness: 1.0,
          ),

          ListTile(
            leading: Icon(Icons.logout, color: Colors.black,),
            title: const Text('Déconnexion'),
            hoverColor: Color(0xFFE8C4F6),
            onTap: () {
              _logout(context);


            },
          ),

        ],
      ),
    );
  }
  void _logout(BuildContext context) async {
    final auth = Provider.of<FirebaseAuthService>(context, listen: false);
    print("Tentative de déconnexion...");

    await auth.signOut(context);
    print("Redirection vers la page de connexion...");

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }


}






