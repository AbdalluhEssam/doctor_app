import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../main.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({Key? key}) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  int _selectedMethod = 1;

  void _handleRadio(int? value) {
    setState(() {
      _selectedMethod = value!;
    });
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      "id": 1,
      "title": "Amazon Pay",
      "image": "assets/amazon.jpg",
    },
    {
      "id": 2,
      "title": "Credit Card",
      "imageRow": [
        "assets/visa.jpg",
        "assets/mastercard.jpg",
      ]
    },
    {
      "id": 3,
      "title": "PayPal",
      "image": "assets/paypal.jpg",
    },
    {
      "id": 4,
      "title": "Meeza",
      "image": "assets/meeza.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Choose Payment Method",
          style: TextStyle(
            fontSize: 20,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const BackButton(color: Colors.teal),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: _paymentMethods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 15),
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    return InkWell(
                      onTap: () {
                        _handleRadio(method["id"]);
                      },
                      child: Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: _selectedMethod == method["id"]
                                ? Colors.teal
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Radio<int>(
                            value: method["id"],
                            groupValue: _selectedMethod,
                            activeColor: Colors.teal,
                            onChanged: _handleRadio,
                          ),
                          title: Text(
                            method["title"],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _selectedMethod == method["id"]
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                          trailing: method["imageRow"] != null
                              ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: (method["imageRow"] as List<String>).map((img) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Image.asset(
                                  img,
                                  width: 40,
                                  height: 30,
                                  fit: BoxFit.contain,
                                ),
                              );
                            }).toList(),
                          )
                              : Image.asset(
                            method["image"],
                            width: 60,
                            height: 40,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 30, color: Colors.teal, thickness: 1.2),
              buildSummaryRow("Sub-Total", "\$300.00"),
              buildSummaryRow("Shipping", "\$15.00"),
              const SizedBox(height: 10),
              buildSummaryRow("Total", "\$315.00", isTotal: true),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text(
                    "Confirm Payment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    MyApp.navigatorKey.currentState!
                        .pushNamed('success_booking');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryRow(String title, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.black : Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 15,
              fontWeight: FontWeight.bold,
              color: isTotal ? Colors.teal : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}