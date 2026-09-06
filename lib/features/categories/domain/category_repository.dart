class Category {
  const Category({required this.id, required this.name, this.color});
  final String id, name;
  final String? color;
}

abstract interface class CategoryRepository {
  Future<List<Category>> list();
  Future<Category> get(String id);
  Future<void> save({String? id, required String name, String? color});
  Future<void> delete(String id);
}
