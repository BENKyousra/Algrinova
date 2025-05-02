import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final double totalPrice;

  const PaymentPage({super.key, required this.totalPrice});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();

  final cardNumberController = TextEditingController();
  final nameController = TextEditingController();
  final cvcController = TextEditingController();

  String selectedMonth = '12 - Decembre';
  String selectedYear = '2025';

  final months = [
    '01 - Janvier',
    '02 - Février',
    '03 - Mars',
    '04 - Avril',
    '05 - Mai',
    '06 - Juin',
    '07 - Juillet',
    '08 - Août',
    '09 - Septembre',
    '10 - Octobre',
    '11 - Novembre',
    '12 - Decembre',
  ];

  final years = List.generate(10, (index) => (2025 + index).toString());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: Colors.white,
        elevation: 2,
        automaticallyImplyLeading: false, // نمنع السلوك الافتراضي
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // زر الرجوع للخلف
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // الشعار
            Image.asset(
              'assets/images/poste_algerie.png',
              height: 60,
              width: 60,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Column(
                children: [
                  const Text(
                    'INFORMATIONS PERSONNELLES',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 23, 41, 209),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(width: 300, height: 3, color: Colors.amber),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'VEUILLEZ ENTRER LES INFORMATIONS DE VOTRE CARTE',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),

              // TOTAL
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(border: Border.all()),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        "TOTAL",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 23, 41, 209),
                        ),
                      ),
                      Text(
                        '${widget.totalPrice.toStringAsFixed(0)} DZD',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // رقم البطاقة
              TextFormField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Numéro de la carte de crédit",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),

              // تاريخ الانتهاء
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Mois',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          months
                              .map(
                                (month) => DropdownMenuItem(
                                  value: month,
                                  child: Text(month),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMonth = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Année',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          years
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedYear = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // الاسم الكامل
              TextFormField(
                controller: cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Numéro de la carte de crédit",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedMonth,
                      decoration: const InputDecoration(
                        labelText: 'Mois',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          months
                              .map(
                                (month) => DropdownMenuItem(
                                  value: month,
                                  child: Text(month),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedMonth = value;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedYear,
                      decoration: const InputDecoration(
                        labelText: 'Année',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          years
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedYear = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nom et Prénom",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: cvcController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Entrez le code CVC2/CVV2",
                  helperText: "Situé au dos de la carte",
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 30),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Traitement en cours...')),
                    );
                  }
                },
                child: const Text(
                  "VALIDER",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 23, 41, 209),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
