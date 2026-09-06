import '../../../core/network/api_client.dart';
import '../domain/category_repository.dart';

class ApiCategoryRepository implements CategoryRepository {
  const ApiCategoryRepository(this.api);
  final ApiClient api;
  Category parse(Map<String, dynamic> data) => Category(
    id: data['id'] as String,
    name: data['name'] as String,
    color: data['color'] as String?,
  );
  @override
  Future<List<Category>> list() async =>
      (await api.getList('categories'))
          .map((e) => parse(e as Map<String, dynamic>))
          .toList();
  @override
  Future<Category> get(String id) async =>
      parse(await api.request('GET', 'categories/$id'));
  @override
  Future<void> save({String? id, required String name, String? color}) async {
    await api.request(
      id == null ? 'POST' : 'PATCH',
      id == null ? 'categories' : 'categories/$id',
      {'name': name, 'color': color},
    );
  }

  @override
  Future<void> delete(String id) async {
    await api.request('DELETE', 'categories/$id');
  }
}
