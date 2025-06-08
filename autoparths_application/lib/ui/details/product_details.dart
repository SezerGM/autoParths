import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import '../../models/product.dart';

class ProductDetails extends StatelessWidget {
  final Product product;

  const ProductDetails({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: SizedBox(height: 30)),
          _buildImage(context),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      title: Text('Детали продукта'),
      centerTitle: false,
      backgroundColor: Colors.lightBlue,
      leading: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: Icon(Icons.arrow_circle_left),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 4,
          child: product.photo != null && product.photo!['data'] != null
              ? Image.memory(
                  Uint8List.fromList(
                    List<int>.from(product.photo!['data']['data']),
                  ),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print('Ошибка загрузки изображения: $error');
                    return Image.asset(
                      'assets/images/images.png',
                      fit: BoxFit.contain,
                    );
                  },
                )
              : Image.asset(
                  'assets/images/images.png',
                  fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Divider(),
            const SizedBox(height: 20),
            
            Text(
              product.name,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            RichText(
              text: TextSpan(
                text: 'Цена: ',
                style: TextStyle(color: Colors.black, fontSize: 20),
                children: [
                  TextSpan(
                    text: '${product.price.toStringAsFixed(2)} ₽',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'Описание: ${product.description}',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 15),
            Text(
              'Категория: ${product.categoryName}',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 15),
            Text(
              'Количество на складе: ${product.quantity}',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Divider(),
            const SizedBox(height: 15),
            Text(
              'Похожие продукты:',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 15),
            Text(
              'Похожие продукты не найдены',
              style: TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
