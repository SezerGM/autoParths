import 'package:autoparths_application/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:typed_data';
import '../details/product_details.dart';
import '../../models/product.dart';

class ItemBuild extends StatelessWidget {
  final Product product;

  const ItemBuild({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    print('Строим ItemBuild для продукта: ${product.name}');
    return Container(
      width: double.infinity,
      color: const Color.fromARGB(255, 225, 224, 222),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: product.photo != null && product.photo!['data'] != null
                  ? Image.memory(
                      Uint8List.fromList(
                        List<int>.from(product.photo!['data']['data']),
                      ),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Ошибка загрузки изображения: $error');
                        return Image.asset(
                          'assets/images/images.png',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.contain,
                        );
                      },
                    )
                  : Image.asset(
                      'assets/images/images.png',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  product.name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'RUB ${product.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                )
              ],
            ),
            Text(product.description),
            Text('Категория: ${product.categoryName}'),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        context.push(Routes.ProductDetails, extra: product);
                      },
                      child: Text('Подробнее'),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Добавить в\n корзину',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}