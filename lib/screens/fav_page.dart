import "package:doctor_appointment_app/components/doctor_card.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/auth_model.dart";

import "package:doctor_appointment_app/components/doctor_card.dart";
import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../models/auth_model.dart";

class FavPage extends StatelessWidget {
  const FavPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                'My Favorite Doctors',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<AuthModel>(
                builder: (context, auth, _) {
                  final favDocs = auth.getFavDoc;

                  if (favDocs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No favorite doctors yet!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: favDocs.length,
                    itemBuilder: (context, index) {
                      final doc = favDocs[index];
                      return DoctorCard(
                        doctor: doc,
                        isFav: true,
                        onFavToggle: () {
                          auth.toggleFavDoctor(doc['doc_id']);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
