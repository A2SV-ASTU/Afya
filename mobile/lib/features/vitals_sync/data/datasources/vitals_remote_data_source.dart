import '../models/vital_sign_model.dart';
import '../../domain/entities/vitals_sync_batch_result_entity.dart';



abstract class VitalsRemoteDataSource {



Future<VitalsSyncBatchResultEntity>
syncVitals(
List<VitalSignModel> vitals
);



Future<List<VitalSignModel>>
getDoctorVitals();



Future<void>
acknowledgeVitals(
List<String> ids
);



Future<List<VitalSignModel>>
getHistory();



}