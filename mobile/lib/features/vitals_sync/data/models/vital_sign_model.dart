import '../../domain/entities/vital_sign_entity.dart';


class VitalSignModel extends VitalSignEntity {


const VitalSignModel({

required super.clientId,

super.systolicBp,

super.diastolicBp,

super.pulse,

super.temperature,

super.spo2,

super.bloodSugar,

super.weight,

required super.source,

required super.recordedAt,

super.synced,

});



factory VitalSignModel.fromJson(
Map<String,dynamic> json
){

return VitalSignModel(

clientId:
json["client_id"],

systolicBp:
json["systolic_bp"],

diastolicBp:
json["diastolic_bp"],

pulse:
json["pulse"],

temperature:
json["temperature"],

spo2:
json["spo2"],

bloodSugar:
json["blood_sugar"],

weight:
json["weight"],

source:
json["source"],

recordedAt:
DateTime.parse(
json["recorded_at"]
),

synced:
json["synced"] ?? false,

);

}





Map<String,dynamic> toJson(){

return {

"client_id":
clientId,

"systolic_bp":
systolicBp,

"diastolic_bp":
diastolicBp,

"pulse":
pulse,

"temperature":
temperature,

"spo2":
spo2,

"blood_sugar":
bloodSugar,

"weight":
weight,

"source":
source,

"recorded_at":
recordedAt.toIso8601String(),


"synced":
synced,

};

}


}