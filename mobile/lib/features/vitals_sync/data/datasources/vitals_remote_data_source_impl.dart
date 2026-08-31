import 'package:injectable/injectable.dart';

import '../../../../core/network/api_client.dart';

import '../../../../core/constants/api_endpoints.dart';

import '../models/vital_sign_model.dart';
import 'vitals_remote_data_source.dart';

import '../../domain/entities/vitals_sync_batch_result_entity.dart';


@LazySingleton(as: VitalsRemoteDataSource)
class VitalsRemoteDataSourceImpl implements VitalsRemoteDataSource {
  final ApiClient apiClient;

  VitalsRemoteDataSourceImpl(this.apiClient);





@override
Future<VitalsSyncBatchResultEntity>
syncVitals(
List<VitalSignModel> vitals
) async {



final response =
await apiClient.dio.post(

ApiEndpoints.vitalsSync,


data:{


"readings":

vitals
.map(
(e)=>e.toJson()
)
.toList()


}


);



return VitalsSyncBatchResultEntity(


uploaded:
response.data["uploaded"],



failed:
response.data["failed"],



failedIds:

List<String>.from(

response.data["failed_ids"]

)


);


}





@override
Future<List<VitalSignModel>>
getDoctorVitals()
async {


final response =
await apiClient.dio.get(

ApiEndpoints.vitalsDoctorSync

);



return (

response.data as List

)

.map(

(e)=>

VitalSignModel.fromJson(e)

)

.toList();



}






@override
Future<void>
acknowledgeVitals(
List<String> ids

)
async {



await apiClient.dio.post(

ApiEndpoints.vitalsDoctorSyncAck,


data:{


"ids":ids


}


);


}






@override
Future<List<VitalSignModel>>
getHistory()

async {


final response =
await apiClient.dio.get(

ApiEndpoints.vitalsHistory

);



return (

response.data as List

)

.map(

(e)=>

VitalSignModel.fromJson(e)

)

.toList();



}



}