abstract interface class AccountRepository {
  Future<String> execute(String action, Map<String, String> fields);
}
