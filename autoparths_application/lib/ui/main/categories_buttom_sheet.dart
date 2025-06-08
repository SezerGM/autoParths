import 'package:flutter/material.dart';
import 'package:autoparths_application/models/category.dart';
import 'package:autoparths_application/services/api_client.dart';

class CategoriesButtomSheet extends StatefulWidget {
  final Function(Category)? onCategorySelected;

  const CategoriesButtomSheet({super.key, this.onCategorySelected});

  @override
  State<CategoriesButtomSheet> createState() => _CategoriesButtomSheetState();
}

class _CategoriesButtomSheetState extends State<CategoriesButtomSheet> {
  List<Category> categories = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await ApiClient().getCategories();
      setState(() {
        categories = loadedCategories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Не удалось загрузить категории';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          SizedBox(height: 20),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (error != null)
            Center(child: Text(error!))
          else
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Center(child: Text(category.name)),
                    
                    onTap: () {
                      if (widget.onCategorySelected != null) {
                        widget.onCategorySelected!(category);
                      }
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
