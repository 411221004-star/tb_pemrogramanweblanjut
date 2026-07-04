import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tb_pmerogramabweblanjut_master/main.dart';

void main() {
  testWidgets('Order history page shows placed orders', (tester) async {
    final order = Order(
      id: 'ORD-001',
      items: [
        OrderItem(product: products.first, quantity: 1),
      ],
      paymentMethod: 'Transfer Bank',
      totalPrice: 142350,
      createdAt: DateTime(2026, 6, 26),
      status: 'Dikirim',
    );

    await tester.pumpWidget(MaterialApp(home: OrderHistoryPage(orders: [order])));

    expect(find.text('Riwayat Pemesanan'), findsOneWidget);
    expect(find.text('ORD-001'), findsOneWidget);
    expect(find.text('Dikirim'), findsOneWidget);
  });
}
