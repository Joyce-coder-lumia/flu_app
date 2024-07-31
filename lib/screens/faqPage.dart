import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  final List<FAQItem> faqItems = [
    FAQItem(
      question: 'Comment créer un compte ?',
      answer: 'Pour créer un compte, cliquez sur "S\'inscrire" sur la page de connexion et suivez les instructions.',
    ),
    FAQItem(
      question: 'Comment annuler un rendez-vous ?',
      answer: 'Cliquez sur "l\'icone menu+" option "Mes rendez-vous" et annuler le rendez-vous selon votre en mettant le motif puis valider.',
    ),
    FAQItem(
      question: 'Comment prendre un rendez-vous avec un médecin ?',
      answer: 'Allez dans la section "Home", choisissez un médecin, une date et une plage d\'horaire, puis confirmez votre rendez-vous.',
    ),
    FAQItem(
      question: 'Comment vérifier l\'état de mes rendez-vous ?',
      answer: 'Allez dans la section "Notification", un message vous sera envoyé pour une confirmation, annulation ou décalage',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FAQ Covhealth'),
        backgroundColor: Color(0xFFAA9DFA),
      ),
      body: ListView.builder(
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(faqItems[index].question),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(faqItems[index].answer),
              ),
            ],
          );
        },
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}
