import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final firestore = FirebaseFirestore.instance;
  print('Seeding Firestore...');

  // Seed users collection
  await firestore.collection('users').doc('user_demo').set({
    'name': 'Demo User',
    'phone': '+1234567890',
    'email': 'demo@example.com',
    'address': '123 Demo St',
    'createdAt': FieldValue.serverTimestamp(),
  });

  // Seed orders collection
  await firestore.collection('orders').doc('order_demo').set({
    'userId': 'user_demo',
    'status': 'pending',
    'items': [
      {'name': 'Shirt', 'quantity': 3, 'type': 'white'},
      {'name': 'Trousers', 'quantity': 2, 'type': 'colored'},
    ],
    'totalAmount': 150.0,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
    'pickupDate': FieldValue.serverTimestamp(),
    'deliveryDate': FieldValue.serverTimestamp(),
    'notes': 'Handle with care',
    'imageUrl': '',
  });

  // Seed schedules collection
  await firestore.collection('schedules').doc('schedule_demo').set({
    'userId': 'user_demo',
    'pickupDate': FieldValue.serverTimestamp(),
    'deliveryDate': FieldValue.serverTimestamp(),
    'status': 'scheduled',
  });

  print('Firestore seeding complete.');
}
