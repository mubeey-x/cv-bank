import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:cv_bank/core/error/exceptions.dart';
import 'package:cv_bank/core/error/supabase_error_mapper.dart';
import '../models/category_model.dart';

abstract interface class CategoryRemoteDataSource {
  Future<List<CategoryModel>> fetchWithCounts({bool includeInactive = false});
  Future<List<CategoryModel>> fetchActiveNames();
  Future<CategoryModel> insert(String name);
  Future<CategoryModel> rename(String id, String name);
  Future<void> setActive(String id, bool isActive);
  Future<void> delete(String id);
  Future<void> reorder(List<String> orderedIds);
}

class CategorySupabaseDataSource implements CategoryRemoteDataSource {
  final SupabaseClient client;
  const CategorySupabaseDataSource(this.client);

  @override
  Future<List<CategoryModel>> fetchWithCounts({bool includeInactive = false}) =>
      mapSupabaseErrors(() async {
        var query = client.from('v_category_breakdown').select();
        if (!includeInactive) query = query.eq('is_active', true);

        final rows = await query.order('sort_order').order('name');
        return rows.map(CategoryModel.fromView).toList();
      });

  @override
  Future<List<CategoryModel>> fetchActiveNames() => mapSupabaseErrors(() async {
    final rows = await client
        .from('categories')
        .select('id, name, sort_order, is_active')
        .eq('is_active', true)
        .order('sort_order')
        .order('name');

    return rows.map(CategoryModel.fromJson).toList();
  });

  @override
  Future<CategoryModel> insert(String name) => mapSupabaseErrors(() async {
    // New categories land at the end. Nulls coalesce to 0 for an
    // account that somehow has none.
    final last = await client
        .from('categories')
        .select('sort_order')
        .order('sort_order', ascending: false)
        .limit(1)
        .maybeSingle();

    final nextOrder = ((last?['sort_order'] as num?)?.toInt() ?? 0) + 1;

    final row = await client
        .from('categories')
        .insert({'name': name, 'sort_order': nextOrder})
        // owner_id defaults to auth.uid() in the schema, so it is
        // never sent from the client.
        .select('id, name, sort_order, is_active')
        .single();

    return CategoryModel.fromJson(row);
  });

  @override
  Future<CategoryModel> rename(String id, String name) =>
      mapSupabaseErrors(() async {
        final row = await client
            .from('categories')
            .update({'name': name})
            .eq('id', id)
            .select('id, name, sort_order, is_active')
            .maybeSingle();

        if (row == null) {
          throw const NotFoundException('That category no longer exists.');
        }
        return CategoryModel.fromJson(row);
      });

  @override
  Future<void> setActive(String id, bool isActive) => mapSupabaseErrors(
    () =>
        client.from('categories').update({'is_active': isActive}).eq('id', id),
  );

  @override
  Future<void> delete(String id) =>
      mapSupabaseErrors(() => client.from('categories').delete().eq('id', id));

  @override
  Future<void> reorder(List<String> orderedIds) => mapSupabaseErrors(() async {
    // One request per row. Fine for a list this size; if it ever
    // grows past ~30 categories, move it to an RPC that takes the
    // array and updates in a single statement.
    await Future.wait([
      for (var i = 0; i < orderedIds.length; i++)
        client
            .from('categories')
            .update({'sort_order': i})
            .eq('id', orderedIds[i]),
    ]);
  });
}
