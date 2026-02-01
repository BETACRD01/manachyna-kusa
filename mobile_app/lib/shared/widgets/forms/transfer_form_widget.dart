// shared/widgets/forms/transfer_form_widget.dart
import 'package:flutter/material.dart';

class TransferFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const TransferFormWidget({
    super.key,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<TransferFormWidget> createState() => _TransferFormWidgetState();
}

class _TransferFormWidgetState extends State<TransferFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final accountNumberController = TextEditingController();
  final accountHolderController = TextEditingController();
  final idNumberController = TextEditingController();
  
  String selectedBank = 'pichincha';
  String selectedAccountType = 'ahorro';

  final List<Map<String, String>> banks = [
    {'id': 'pichincha', 'name': 'Banco Pichincha'},
    {'id': 'pacifico', 'name': 'Banco del Pacífico'},
    {'id': 'guayaquil', 'name': 'Banco de Guayaquil'},
    {'id': 'produbanco', 'name': 'Produbanco'},
    {'id': 'bolivariano', 'name': 'Banco Bolivariano'},
  ];

  final List<Map<String, String>> accountTypes = [
    {'id': 'ahorro', 'name': 'Cuenta de Ahorros'},
    {'id': 'corriente', 'name': 'Cuenta Corriente'},
  ];

  @override
  void dispose() {
    accountNumberController.dispose();
    accountHolderController.dispose();
    idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: Colors.purple[600], size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Datos de Transferencia',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onCancel,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Form
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Selección de banco
                    DropdownButtonFormField<String>(
                      initialValue: selectedBank,
                      decoration: const InputDecoration(
                        labelText: 'Banco',
                        prefixIcon: Icon(Icons.account_balance),
                        border: OutlineInputBorder(),
                      ),
                      items: banks.map((bank) {
                        return DropdownMenuItem<String>(
                          value: bank['id'],
                          child: Text(bank['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBank = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Tipo de cuenta
                    DropdownButtonFormField<String>(
                      initialValue: selectedAccountType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de cuenta',
                        prefixIcon: Icon(Icons.account_balance_wallet),
                        border: OutlineInputBorder(),
                      ),
                      items: accountTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type['id'],
                          child: Text(type['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedAccountType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Número de cuenta
                    TextFormField(
                      controller: accountNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de cuenta',
                        hintText: '1234567890',
                        prefixIcon: Icon(Icons.numbers),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el número de cuenta';
                        }
                        if (value.length < 8) {
                          return 'Número de cuenta inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Titular de la cuenta
                    TextFormField(
                      controller: accountHolderController,
                      decoration: const InputDecoration(
                        labelText: 'Titular de la cuenta',
                        hintText: 'Nombre completo del titular',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el nombre del titular';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Número de cédula/RUC
                    TextFormField(
                      controller: idNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Cédula o RUC',
                        hintText: '1234567890',
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ingrese el número de identificación';
                        }
                        if (value.length < 10) {
                          return 'Número de identificación inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Información importante
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info, color: Colors.orange[600]),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'La transferencia debe realizarse antes del inicio del servicio. Recibirás los datos de la cuenta del proveedor.',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Botones
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              ),
                            ),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _onSavePressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple[600],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)
                              ),
                            ),
                            child: const Text(
                              'Guardar Datos',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onSavePressed() {
    if (_formKey.currentState!.validate()) {
      final transferData = {
        'bank': selectedBank,
        'bankName': banks.firstWhere((b) => b['id'] == selectedBank)['name'],
        'accountType': selectedAccountType,
        'accountTypeName': accountTypes.firstWhere((t) => t['id'] == selectedAccountType)['name'],
        'accountNumber': accountNumberController.text,
        'accountHolder': accountHolderController.text,
        'idNumber': idNumberController.text,
      };
      widget.onSave(transferData);
    }
  }
}
