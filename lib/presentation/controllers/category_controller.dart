import 'package:get/get.dart';
import 'package:medigram/data/models/category.dart';
import 'package:medigram/data/services/category_service.dart';
import 'package:medigram/core/utils/snackbar_helper.dart';

class CategoryController extends GetxController {
  final CategoryService _categoryService = CategoryService();

  // Observable state
  final RxList<Category> _categories = <Category>[].obs;
  final RxBool _isLoading = false.obs;
  final Rx<Category?> _selectedCategory = Rx<Category?>(null);

  // Getters
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading.value;
  Category? get selectedCategory => _selectedCategory.value;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Fetch categories
  Future<void> fetchCategories({bool activeOnly = true}) async {
    try {
      _isLoading.value = true;

      final categories = await _categoryService.getCategories(
        activeOnly: activeOnly,
      );

      _categories.value = categories;
    } catch (e) {
      SnackbarHelper.showError('Kategoriler yüklenirken hata oluştu: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  // Select category
  void selectCategory(Category? category) {
    _selectedCategory.value = category;
  }

  // Clear selected category
  void clearSelection() {
    _selectedCategory.value = null;
  }

  // Get category by name
  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  // Refresh categories
  Future<void> refresh() async {
    await fetchCategories();
  }
}
