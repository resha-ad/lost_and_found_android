import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:lost_n_found/core/constants/hive_table_constants.dart';
import 'package:lost_n_found/features/auth/data/models/auth_hive_model.dart';
import 'package:lost_n_found/features/batch/data/models/batch_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final HiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  //init
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    //C:/resha/abcdee/lost_and_found_db
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
    await insertDummybatches();
  }

  Future<void> insertDummybatches() async {
    final box = Hive.box<BatchHiveModel>(HiveTableConstant.batchTable);
    if (box.isNotEmpty) return;

    final dummyBatches = [
      BatchHiveModel(batchName: "35-A"),
      BatchHiveModel(batchName: "35-B"),
      BatchHiveModel(batchName: "35-C"),
      BatchHiveModel(batchName: "36-A"),
      BatchHiveModel(batchName: "36-B"),
      BatchHiveModel(batchName: "37-C"),
    ];
    for (var batch in dummyBatches) {
      await box.put(batch.batchId, batch);
    }
    await box.close();
  }

  //Register Adapters
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.batchTypeId)) {
      Hive.registerAdapter(BatchHiveModelAdapter());
    }

    //register other adapters here
    if (!Hive.isAdapterRegistered(HiveTableConstant.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
  }

  //Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<BatchHiveModel>(HiveTableConstant.batchTable);
    await Hive.openBox<AuthHiveModel>(HiveTableConstant.authTable);
  }

  //Close Boxes
  Future<void> close() async {
    await Hive.close();
  }

  //**********************Batch Queries**************************
  Box<BatchHiveModel> get _batchBox =>
      Hive.box<BatchHiveModel>(HiveTableConstant.batchTable);

  //Create
  Future<BatchHiveModel> createBatch(BatchHiveModel model) async {
    await _batchBox.put(model.batchId, model);
    return model;
  }

  //getallbatch
  List<BatchHiveModel> getAllBatches() {
    return _batchBox.values.toList();
  }

  //update
  Future<void> updateBranch(BatchHiveModel model) async {
    await _batchBox.put(model.batchId, model);
  }

  //delete

  //**********************Auth Queries**************************
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstant.authTable);
  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  //Login
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  //Logout
  Future<void> logoutUser() async {}

  //get Current User
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  //isEmailExists
  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}
