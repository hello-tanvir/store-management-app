import '../../helpers/database_helper.dart';
import '../models/store_model.dart';
import 'firebase_service.dart';
import 'geocoding_service.dart';

class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  final FirebaseService _firebaseService =
      FirebaseService.instance;

  Future<void> syncStores() async {
    try {
      final unsyncedStores =
      await _databaseHelper.getUnsyncedStores();

      print('UNSYNCED COUNT: ${unsyncedStores.length}');

      for (final store in unsyncedStores) {
        print('SYNCING STORE ID: ${store.id}');
        await _syncStore(store);
      }
    } catch (e) {
      print('SYNC FAILED: $e');
    }
  }

  Future<void> _syncStore(
      StoreModel store,
      ) async {
    try {
      print('STORE ID: ${store.id}');
      print('STORE ADDRESS: ${store.address}');
        print('IS SYNCED: ${store.isSynced}');

      String? address = store.address;

      if (address == null || address.trim().isEmpty) {
        print('ADDRESS NOT FOUND -> NOMINATIM START');

        address = await GeocodingService.getAddress(
          latitude: store.latitude,
          longitude: store.longitude,
        );

        print('NOMINATIM ADDRESS: $address');
      }


      if (address == null || address.trim().isEmpty) {
        print('ADDRESS NULL -> SYNC STOPPED');
        return;
      }

      final updatedStore = StoreModel(
        id: store.id,
        storeName: store.storeName,
        ownerName: store.ownerName,
        mobileNumber: store.mobileNumber,
        storeType: store.storeType,
        latitude: store.latitude,
        longitude: store.longitude,
        address: address,
        createdAt: store.createdAt,
        isSynced: false,
      );

      print('FIREBASE UPLOAD START');

      // Firebase এ পুরো store upload
      await _firebaseService.uploadStore(
        updatedStore,
      );

      print('FIREBASE UPLOAD SUCCESS');

      // SQLite তে address save
      if (store.id != null) {
        await _databaseHelper.updateAddress(
          store.id!,
          address,
        );

        print('SQLITE ADDRESS UPDATED');

        // Sync complete
        await _databaseHelper.markAsSynced(
          store.id!,
        );

        print('SQLITE SYNC STATUS UPDATED -> 1');
      }
    } catch (e) {
      print(
        'STORE SYNC FAILED (ID: ${store.id}): $e',
      );
    }
  }
}