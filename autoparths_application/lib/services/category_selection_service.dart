import '../models/category.dart';

class CategorySelectionService {
  static final CategorySelectionService _instance = CategorySelectionService._internal();

  factory CategorySelectionService() {
    return _instance;
  }

  CategorySelectionService._internal();

  Category? _selectedCategory;

  Category? get selectedCategory => _selectedCategory;

  void selectCategory(Category category) {
    _selectedCategory = category;
  }

  void clearSelection() {
    _selectedCategory = null;
  }
} 