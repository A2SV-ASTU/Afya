import 'package:injectable/injectable.dart';
import '../entities/vital_sign_entity.dart';
import '../repositories/vitals_repository.dart';

@lazySingleton
class SaveHomeVitalOfflineUseCase {


final VitalsRepository repository;


SaveHomeVitalOfflineUseCase(
this.repository
);



Future<void> call(
VitalSignEntity vital
){

return repository.saveVitalOffline(vital);

}


}