import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/store_model.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> uploadStore(StoreModel store) async {
    if (store.id == null) {
      throw Exception('Store ID is required');
    }

    await _firestore
        .collection('stores')
        .doc(store.id.toString())
        .set({
      'storeName': store.storeName,
      'ownerName': store.ownerName,
      'mobileNumber': store.mobileNumber,
      'storeType': store.storeType,
      'latitude': store.latitude,
      'longitude': store.longitude,
      'address': store.address,
      'createdAt': store.createdAt,
    });
  }
}