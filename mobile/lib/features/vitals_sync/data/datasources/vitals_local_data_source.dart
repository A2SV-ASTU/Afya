import '../models/vital_sign_model.dart';


abstract class VitalsLocalDataSource {


Future<void> saveVital(
VitalSignModel vital
);



Future<List<VitalSignModel>>
getPendingVitals();



Future<void>
deleteSyncedVitals(
List<String> ids
);



Future<int>
getPendingCount();



}