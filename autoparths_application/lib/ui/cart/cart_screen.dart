import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
        centerTitle: false,
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          // Место для списка товаров в корзине
          Expanded(
            child: ListView.builder(
              itemCount: 0, // Пока нет товаров
              itemBuilder: (context, index) {
                // Здесь будет виджет для отображения одного товара в корзине
                return ListTile(
                  title: Text('Название товара'),
                  subtitle: Text('Цена x Количество'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      // TODO: Удалить товар из корзины
                    },
                  ),
                );
              },
            ),
          ),
          
          // Место для отображения итоговой суммы
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Итого:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '0.00 ₽', // TODO: Отображать реальную сумму
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Кнопка оформления заказа
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Перейти к оформлению заказа
              },
              child: const Text('Оформить заказ'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50), // Кнопка на всю ширину
                backgroundColor: Colors.lightBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}