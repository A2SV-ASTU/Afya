import 'package:injectable/injectable.dart';
import '../entities/vitals_sync_batch_result_entity.dart';
import '../repositories/vitals_repository.dart';


@lazySingleton
class SyncVitalsUseCase {


final VitalsRepository repository;


SyncVitalsUseCase(
this.repository
);



Future<VitalsSyncBatchResultEntity> call(){

return repository.syncVitals();

}


}