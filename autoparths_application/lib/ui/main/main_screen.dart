import 'package:autoparths_application/ui/main/categories_buttom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:autoparths_application/models/product.dart';
import 'package:autoparths_application/models/category.dart';
import 'package:autoparths_application/services/api_client.dart';

import 'price_bottom_sheet.dart';
import 'item_build.dart';
import '../widgets/search_field.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ScrollController _scrollController = ScrollController();
  List<Product> products = [];
  List<Product> filteredProducts = [];
  bool isLoading = true;
  String? error;
  Category? selectedCategory;
  PriceRange? selectedPriceRange;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      print('Начинаем загрузку продуктов...');
      final loadedProducts = await ApiClient().getProducts();
      print('Получено продуктов: ${loadedProducts.length}');
      setState(() {
        products = loadedProducts;
        _applyFilters();
        isLoading = false;
        error = null;
      });
    } catch (e) {
      print('Ошибка при загрузке продуктов: $e');
      setState(() {
        isLoading = false;
        error = 'Не удалось загрузить продукты. Пожалуйста, проверьте подключение к интернету и попробуйте снова.';
      });
    }
  }

  Future<void> _loadProductsByCategory(Category category) async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });
      
      print('Загрузка продуктов для категории: ${category.name} (${category.slug})');
      final loadedProducts = await ApiClient().getProductsByCategory(category.slug);
      print('Получено продуктов для категории: ${loadedProducts.length}');
      
      setState(() {
        products = loadedProducts;
        selectedCategory = category;
        _applyFilters();
        isLoading = false;
      });
    } catch (e) {
      print('Ошибка при загрузке продуктов категории: $e');
      setState(() {
        isLoading = false;
        error = 'Не удалось загрузить продукты категории';
      });
    }
  }

  void _onCategorySelected(Category category) {
    _loadProductsByCategory(category);
  }

  void _onPriceRangeSelected(PriceRange range) {
    setState(() {
      selectedPriceRange = range;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      filteredProducts = products.where((product) {
        if (selectedPriceRange == null) return true;
        
        final price = product.price;
        final minPrice = selectedPriceRange!.minPrice;
        final maxPrice = selectedPriceRange!.maxPrice;

        if (minPrice != null && price < minPrice) return false;
        if (maxPrice != null && price > maxPrice) return false;
        
        return true;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(context),
            _buildCategories(context),
            if (isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(error!),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loadProducts,
                        child: Text('Повторить'),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildCatalog(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      title: Text('Главная страница'),
      backgroundColor: Colors.blue,
      leading: Icon(Icons.car_repair_outlined),
      centerTitle: false,
    );
  }

  Widget _buildCategories(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 0),
      sliver: SliverToBoxAdapter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Icon(Icons.arrow_drop_down),
                  TextButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => CategoriesButtomSheet(
                          onCategorySelected: _onCategorySelected,
                        ),
                      );
                    },
                    child: Text(selectedCategory?.name ?? 'Категории'),
                  ),
                  if (selectedCategory != null)
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          selectedCategory = null;
                          _loadProducts();
                        });
                      },
                    ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_drop_down),
                    TextButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => PriceBottomSheet(
                            onPriceRangeSelected: _onPriceRangeSelected,
                          ),
                        );
                      },
                      child: Text(selectedPriceRange != null
                          ? 'Цена: ${_getPriceRangeText()}'
                          : 'Цена'),
                    ),
                    if (selectedPriceRange != null)
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            selectedPriceRange = null;
                            _applyFilters();
                          });
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPriceRangeText() {
    if (selectedPriceRange == null) return '';
    
    final min = selectedPriceRange!.minPrice;
    final max = selectedPriceRange!.maxPrice;
    
    if (min == null && max != null) return 'до ${max} ₽';
    if (min != null && max == null) return 'от ${min} ₽';
    if (min != null && max != null) return '${min}-${max} ₽';
    return '';
  }

  Widget _buildCatalog(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          children: [
            ...List.generate(
              filteredProducts.length,
              (index) => [
                SizedBox(height: 10),
                ItemBuild(product: filteredProducts[index]),
              ],
            ).expand((e) => e).toList(),
          ],
        ),
      ),
    );
  }
}
