import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/transaction.dart';
import '../../models/category.dart';
import '../../models/transaction_type.dart';
import 'package:myfinance/bloc/transaction/transaction_bloc.dart';
import 'package:myfinance/bloc/transaction/transaction_event.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';
import '../widgets/category_badge.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final Transaction? transaction;

  const AddEditTransactionScreen({Key? key, this.transaction}) : super(key: key);

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  Category _selectedCategory = Category.food;
  TransactionType _selectedType = TransactionType.expense;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _noteController.text = widget.transaction!.note;
      _selectedDate = widget.transaction!.date;
      _selectedCategory = widget.transaction!.category;
      _selectedType = widget.transaction!.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Amount
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: Validators.validateAmount,
            ),
            const SizedBox(height: 16),

            // Type
            DropdownButtonFormField<TransactionType>(
              value: _selectedType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: TransactionType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: Category.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: CategoryBadge(category: category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Date
            ListTile(
              title: const Text('Date'),
              subtitle: Text(AppFormatters.formatDate(_selectedDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note (Optional)',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _saveTransaction,
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _saveTransaction() {
    if (_formKey.currentState?.validate() ?? false) {
      final amount = double.parse(_amountController.text);
      final transaction = widget.transaction?.copyWith(
            amount: amount,
            category: _selectedCategory,
            type: _selectedType,
            date: _selectedDate,
            note: _noteController.text,
          ) ??
          Transaction.create(
            amount: amount,
            category: _selectedCategory,
            type: _selectedType,
            date: _selectedDate,
            note: _noteController.text,
          );

      if (widget.transaction != null) {
        context.read<TransactionBloc>().add(UpdateTransaction(transaction));
      } else {
        context.read<TransactionBloc>().add(AddTransaction(transaction));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}
