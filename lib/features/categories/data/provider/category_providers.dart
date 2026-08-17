import 'package:cv_bank/core/provider/supabase_provider.dart';
import 'package:cv_bank/features/categories/data/repositories/category_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:cv_bank/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:cv_bank/features/categories/domain/repositories/category_repository.dart';
import 'package:cv_bank/features/categories/domain/usecases/manage_categories.dart';

part 'category_providers.g.dart';

// ============================================================================
// DATA LAYER
// ============================================================================

@Riverpod(keepAlive: true)
CategoryRemoteDataSource categoryRemoteDataSource(Ref ref) {
  return CategorySupabaseDataSource(ref.watch(supabaseProvider));
}

@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(Ref ref) {
  return CategoryRepositoryImpl(
    remote: ref.watch(categoryRemoteDataSourceProvider),
  );
}

// ============================================================================
// DOMAIN LAYER (Use Cases)
// ============================================================================

@riverpod
GetCategories getCategories(Ref ref) =>
    GetCategories(ref.watch(categoryRepositoryProvider));

@riverpod
GetActiveCategoryNames getActiveCategoryNames(Ref ref) =>
    GetActiveCategoryNames(ref.watch(categoryRepositoryProvider));

@riverpod
CreateCategory createCategory(Ref ref) =>
    CreateCategory(ref.watch(categoryRepositoryProvider));

@riverpod
RenameCategory renameCategory(Ref ref) =>
    RenameCategory(ref.watch(categoryRepositoryProvider));

@riverpod
SetCategoryActive setCategoryActive(Ref ref) =>
    SetCategoryActive(ref.watch(categoryRepositoryProvider));

@riverpod
DeleteCategory deleteCategory(Ref ref) =>
    DeleteCategory(ref.watch(categoryRepositoryProvider));

@riverpod
ReorderCategories reorderCategories(Ref ref) =>
    ReorderCategories(ref.watch(categoryRepositoryProvider));
