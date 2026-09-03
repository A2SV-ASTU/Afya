import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:afyamind_mobile/features/vitals_sync/domain/repositories/vitals_repository.dart';
import 'package:afyamind_mobile/features/vitals_sync/domain/usecases/sync_vitals_usecase.dart';
import 'package:afyamind_mobile/features/vitals_sync/domain/entities/vitals_sync_batch_result_entity.dart';
class MockVitalsRepository
extends Mock
implements VitalsRepository {}



void main(){


late MockVitalsRepository repository;

late SyncVitalsUseCase useCase;



setUp((){


repository =
MockVitalsRepository();



useCase =
SyncVitalsUseCase(repository);


});



test(
"should sync pending vitals",
() async {


when(
()=>repository.syncVitals()
)

.thenAnswer(

(_)=>

Future.value(

const VitalsSyncBatchResultEntity(

uploaded:5,

failed:0,

failedIds:[]

)

)

);



final result =
await useCase();



expect(
result.uploaded,
5
);



verify(
()=>repository.syncVitals()
).called(1);



}

);


}