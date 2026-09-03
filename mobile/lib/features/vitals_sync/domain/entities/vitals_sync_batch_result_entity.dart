class VitalsSyncBatchResultEntity {

  final int uploaded;
  final int failed;
  final List<String> failedIds;


  const VitalsSyncBatchResultEntity({
    required this.uploaded,
    required this.failed,
    required this.failedIds,
  });
}