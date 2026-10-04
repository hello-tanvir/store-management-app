import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/models/store_model.dart';
import '../data/service/sync_service.dart';
import '../helpers/database_helper.dart';

class AddDetailsScreen extends StatefulWidget {
  const AddDetailsScreen({super.key});

  @override
  State<AddDetailsScreen> createState() => _AddDetailsScreenState();
}

class _AddDetailsScreenState extends State<AddDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController storeNameController =
  TextEditingController();

  final TextEditingController ownerNameController =
  TextEditingController();

  final TextEditingController mobileNumberController =
  TextEditingController();

  String? selectedStoreType;

  List<StoreModel> stores = [];

  final List<String> storeTypes = [
    'Grocery Store',
    'Clothing Store',
    'Electronics Store',
    'Pharmacy',
    'Restaurant',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    loadStores();
  }

  Future<void> loadStores() async {
    final data = await DatabaseHelper.instance.getStores();

    if (!mounted) return;

    setState(() {
      stores = data;
    });
  }

  Future<void> deleteStore(int id) async {
    await DatabaseHelper.instance.deleteStore(id);
    await loadStores();
  }

  Future<void> updateStore(int id, BuildContext bottomSheetContext,) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await DatabaseHelper.instance.updateStore(
        id,
        {
          'store_name': storeNameController.text.trim(),
          'owner_name': ownerNameController.text.trim(),
          'mobile_number': mobileNumberController.text.trim(),
          'store_type': selectedStoreType!,
          'is_synced': 0,
        },
      );

      // Updated store আবার Firebase-এ পাঠানোর চেষ্টা
      await SyncService.instance.syncStores();

      if (mounted && Navigator.canPop(bottomSheetContext)) {
        Navigator.pop(bottomSheetContext);
      }
    } catch (e) {
      debugPrint('Update store error: $e');

      if (mounted) {
        Navigator.pop(bottomSheetContext);
      }
    }
  }

  @override
  void dispose() {
    storeNameController.dispose();
    ownerNameController.dispose();
    mobileNumberController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Details'),
      ),
      body: stores.isEmpty
          ? const Center(
        child: Text(
          'No stores added yet',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final store = stores[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.store_rounded,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.storeName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              store.storeType,
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              showEditStoreSheet(store);
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.red,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Delete Store'),
                                    content: const Text(
                                      'Are you sure you want to delete this store?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('No'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          deleteStore(store.id!);
                                        },
                                        child: const Text(
                                          'Yes',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          store.ownerName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.phone_outlined,
                        size: 19,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        store.mobileNumber,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 20,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          store.address ??
                              '${store.latitude.toStringAsFixed(5)}, '
                                  '${store.longitude.toStringAsFixed(5)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        store.isSynced
                            ? Icons.cloud_done
                            : Icons.cloud_off,
                        size: 18,
                        color: store.isSynced
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        store.isSynced
                            ? 'Synced'
                            : 'Not synced',
                        style: TextStyle(
                          fontSize: 12,
                          color: store.isSynced
                              ? Colors.green
                              : Colors.orange,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddStoreSheet();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void showAddStoreSheet() {
    clearForm();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                MediaQuery.of(bottomSheetContext)
                    .viewInsets
                    .bottom +
                    20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: buildStoreForm(
                    bottomSheetContext,
                    isEdit: false,
                    isSaving: isSaving,
                    onSave: () async {
                      FocusScope.of(context).unfocus();

                      setSheetState(() {
                        isSaving = true;
                      });

                      try {
                        await addStore(
                          bottomSheetContext,
                        );
                      } finally {
                        if (mounted) {
                          setSheetState(() {
                            isSaving = false;
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() async {
      clearForm();
      await loadStores();
    });
  }

  void showEditStoreSheet(StoreModel store) {
    storeNameController.text = store.storeName;
    ownerNameController.text = store.ownerName;
    mobileNumberController.text = store.mobileNumber;

    selectedStoreType = store.storeType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom:
                MediaQuery.of(bottomSheetContext)
                    .viewInsets
                    .bottom +
                    20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: buildStoreForm(
                    bottomSheetContext,
                    isEdit: true,
                    storeId: store.id!,
                    isSaving: isSaving,
                    onSave: () async {
                      setSheetState(() {
                        isSaving = true;
                      });

                      try {
                        await updateStore(
                          store.id!,
                          bottomSheetContext,
                        );
                      } finally {
                        if (mounted) {
                          setSheetState(() {
                            isSaving = false;
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() async {
      clearForm();
      await loadStores();
    });
  }

  Widget buildStoreForm(
      BuildContext bottomSheetContext, {
        required bool isEdit,
        int? storeId,
        required bool isSaving,
        required VoidCallback onSave,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            height: 5,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius:
              BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(height: 20),

        Text(
          isEdit ? 'Edit Store' : 'Add Store',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller: storeNameController,
          enabled: !isSaving,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Store Name',
            hintText: 'Enter store name',
            prefixIcon:
            const Icon(Icons.store_outlined),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter store name';
            }

            if (value.trim().length < 2) {
              return 'Store name must be at least 2 characters';
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller: ownerNameController,
          enabled: !isSaving,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Owner Name',
            hintText: 'Enter owner name',
            prefixIcon:
            const Icon(Icons.person_outline),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter owner name';
            }

            if (value.trim().length < 2) {
              return 'Owner name must be at least 2 characters';
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        TextFormField(
          controller: mobileNumberController,
          enabled: !isSaving,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            hintText: '01XXXXXXXXX',
            prefixIcon:
            const Icon(Icons.phone_outlined),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) {
            if (value == null ||
                value.trim().isEmpty) {
              return 'Please enter mobile number';
            }

            final mobile = value.trim();

            if (!RegExp(
              r'^01[3-9]\d{8}$',
            ).hasMatch(mobile)) {
              return 'Enter a valid Bangladeshi mobile number';
            }

            return null;
          },
        ),

        const SizedBox(height: 14),

        DropdownButtonFormField<String>(
          value: selectedStoreType,
          decoration: InputDecoration(
            labelText: 'Store Type',
            prefixIcon:
            const Icon(Icons.category_outlined),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius:
              BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text(
            'Select store type',
          ),
          items: storeTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(type),
            );
          }).toList(),
          validator: (value) {
            if (value == null ||
                value.isEmpty) {
              return 'Please select store type';
            }

            return null;
          },
          onChanged: isSaving
              ? null
              : (value) {
            setState(() {
              selectedStoreType = value;
            });
          },
        ),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isSaving ? null : onSave,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(16),
              ),
            ),
            child: isSaving
                ? const SizedBox(
              height: 24,
              width: 24,
              child:
              CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            )
                : Text(
              isEdit
                  ? 'Update Store'
                  : 'Add Store',
              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void clearForm() {
    storeNameController.clear();
    ownerNameController.clear();
    mobileNumberController.clear();

    if (mounted) {
      setState(() {
        selectedStoreType = null;
      });
    }

    _formKey.currentState?.reset();
  }

  /*Future<void> addStore(BuildContext bottomSheetContext,) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission ==
          LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        return;
      }

      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint(
          'Location service is disabled.',
        );
        return;
      }

      final Position position =
      await Geolocator.getCurrentPosition();

      final store = StoreModel(
        storeName:
        storeNameController.text.trim(),
        ownerName:
        ownerNameController.text.trim(),
        mobileNumber:
        mobileNumberController.text.trim(),
        storeType: selectedStoreType!,
        latitude: position.latitude,
        longitude: position.longitude,
        address: null,
        createdAt:
        DateTime.now().toIso8601String(),
        isSynced: false,
      );

      await DatabaseHelper.instance.insertStore(
        store,
      );

      // Internet থাকলে সাথে সাথে sync করার চেষ্টা করবে।
      // Internet না থাকলে SQLite data থেকে যাবে।
      await SyncService.instance.syncStores();

      if (mounted) {
        Navigator.pop(bottomSheetContext);
      }
    } catch (e) {
      debugPrint(
        'Add store error: $e',
      );

      // SQLite-তে save হয়ে থাকলে এখানেও bottom sheet close হবে।
      if (mounted) {
        Navigator.pop(bottomSheetContext);
      }
    }
  }*/
  Future<void> addStore(BuildContext bottomSheetContext,) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint(
          'Location service is disabled.',
        );
        return;
      }

      final Position position =
      await Geolocator.getCurrentPosition();

      final store = StoreModel(
        storeName:
        storeNameController.text.trim(),
        ownerName:
        ownerNameController.text.trim(),
        mobileNumber:
        mobileNumberController.text.trim(),
        storeType: selectedStoreType!,
        latitude: position.latitude,
        longitude: position.longitude,
        address: null,
        createdAt:
        DateTime.now().toIso8601String(),
        isSynced: false,
      );

      final id =
      await DatabaseHelper.instance.insertStore(
        store,
      );
      debugPrint(
        'NEW SQLITE ID: $id',
      );

      await SyncService.instance.syncStores();

      if (mounted) {
        Navigator.pop(bottomSheetContext);
      }
    } catch (e) {
      debugPrint(
        'Add store error: $e',
      );

      if (mounted) {
        Navigator.pop(bottomSheetContext);
      }
    }
  }
}