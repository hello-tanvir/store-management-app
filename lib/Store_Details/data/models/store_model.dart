class StoreModel {
  final int? id;
  final String storeName;
  final String ownerName;
  final String mobileNumber;
  final String storeType;
  final double latitude;
  final double longitude;
  final String? address;
  final String createdAt;
  final bool isSynced;

  StoreModel({
    this.id,
    required this.storeName,
    required this.ownerName,
    required this.mobileNumber,
    required this.storeType,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.createdAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'store_name': storeName,
      'owner_name': ownerName,
      'mobile_number': mobileNumber,
      'store_type': storeType,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'created_at': createdAt,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory StoreModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return StoreModel(
      id: map['id'],
      storeName: map['store_name'],
      ownerName: map['owner_name'],
      mobileNumber: map['mobile_number'],
      storeType: map['store_type'],
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      address: map['address'],
      createdAt: map['created_at'],
      isSynced: map['is_synced'] == 1,
    );
  }
}