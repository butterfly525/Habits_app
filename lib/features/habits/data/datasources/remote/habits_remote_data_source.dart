/// Placeholder for future API integration.
/// Keep the interface close to local datasource operations to simplify sync.
abstract class HabitsRemoteDataSource {
  Future<void> pullHabits();
  Future<void> pushDirtyChanges();
}

class NoopHabitsRemoteDataSource implements HabitsRemoteDataSource {
  @override
  Future<void> pullHabits() async {}

  @override
  Future<void> pushDirtyChanges() async {}
}
