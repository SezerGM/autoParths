import 'package:flutter/material.dart';

class PriceRange {
  final double? minPrice;
  final double? maxPrice;

  PriceRange({this.minPrice, this.maxPrice});
}

class PriceBottomSheet extends StatelessWidget {
  final Function(PriceRange) onPriceRangeSelected;

  const PriceBottomSheet({
    super.key,
    required this.onPriceRangeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Выберите диапазон цен',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          _buildPriceOption(
            context,
            'До 500 ₽',
            PriceRange(maxPrice: 500),
          ),
          _buildPriceOption(
            context,
            'От 500 ₽ до 999 ₽',
            PriceRange(minPrice: 500, maxPrice: 999),
          ),
          _buildPriceOption(
            context,
            'От 1000 ₽ до 1499 ₽',
            PriceRange(minPrice: 1000, maxPrice: 1499),
          ),
          _buildPriceOption(
            context,
            'От 1500 ₽ до 2999 ₽',
            PriceRange(minPrice: 1500, maxPrice: 2999),
          ),
          _buildPriceOption(
            context,
            'От 3000 ₽',
            PriceRange(minPrice: 3000),
                ),
          _buildPriceOption(
            context,
            'Сбросить фильтр',
            PriceRange(),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceOption(BuildContext context, String title, PriceRange range) {
    return InkWell(
      onTap: () {
        onPriceRangeSelected(range);
        Navigator.pop(context);
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Text(
          title,
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
