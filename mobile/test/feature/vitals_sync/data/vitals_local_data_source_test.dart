import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';


import 'package:afyamind_mobile/features/vitals_sync/data/datasources/vitals_local_data_source_impl.dart';

import 'package:afyamind_mobile/features/vitals_sync/data/models/vital_sign_model.dart';



void main(){


late Box box;

late VitalsLocalDataSourceImpl dataSource;



setUp(() async {


await setUpTestHive();


box =
await Hive.openBox(
"vitals_outbox"
);



dataSource =
VitalsLocalDataSourceImpl(box);


});



tearDown(() async {


await tearDownTestHive();


});





test(
"should save vital locally",
() async {


final vital =
VitalSignModel(

clientId:"123",

pulse:80,

temperature:36.5,

source:"patient",

recordedAt:
DateTime.now()

);



await dataSource.saveVital(vital);



final result =
await dataSource.getPendingVitals();



expect(
result.length,
1
);



expect(
result.first.clientId,
"123"
);


}

);





test(
"should delete synced vitals",
() async {


final vital =
VitalSignModel(

clientId:"abc",

pulse:70,

source:"patient",

recordedAt:
DateTime.now()

);



await dataSource.saveVital(vital);



await dataSource.deleteSyncedVitals(
["abc"]
);



final result =
await dataSource.getPendingVitals();



expect(
result.isEmpty,
true
);



}

);


}