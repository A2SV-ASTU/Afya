import '../../domain/entities/vital_sign_entity.dart';


sealed class VitalsSyncEvent {}


/// Load pending offline vitals
class LoadPendingVitalsEvent extends VitalsSyncEvent {}


/// Save a new vital locally
class SaveVitalEvent extends VitalsSyncEvent {

  final VitalSignEntity vital;


  SaveVitalEvent(this.vital);

}



/// Start synchronization
class SyncVitalsEvent extends VitalsSyncEvent {}


/// Network restored
class NetworkRestoredEvent extends VitalsSyncEvent {}


/// Get history
class LoadVitalsHistoryEvent extends VitalsSyncEvent {}