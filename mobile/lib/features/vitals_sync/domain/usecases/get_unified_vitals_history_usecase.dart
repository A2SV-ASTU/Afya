import 'package:injectable/injectable.dart';
import '../entities/vital_sign_entity.dart';
import '../repositories/vitals_repository.dart';


@lazySingleton
class GetUnifiedVitalsHistoryUseCase {


final VitalsRepository repository;


GetUnifiedVitalsHistoryUseCase(
this.repository
);



Future<List<VitalSignEntity>> call(){

return repository.getHistory();

}


}