import 'package:expense_tracker_app_hive/components/my_list_tile.dart';
import 'package:expense_tracker_app_hive/database/expense_database.dart';
import 'package:expense_tracker_app_hive/helper/helper_functions.dart';
import 'package:expense_tracker_app_hive/models/expense.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //text controller
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    super.initState();
  }

  //new expensebox
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //input expense name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Name",
              ),
            ),
            //input expense amount
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                hintText: "Amount",
              ),
            ),
          ],
        ),
        actions: [
          //cancel button
          _cancelButton(),
          //save button
          _createNewExpenseButton()
        ],
      ),
    );
  }

  // open edit box
  void openEditBox(Expense expense) {
    //pre-fill existing values into the text fields
    String existingName = expense.name;
    String existingAmount = expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //input expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: existingName,
              ),
            ),
            //input expense amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(
                hintText: existingAmount,
              ),
            ),
          ],
        ),
        actions: [
          //cancel button
          _cancelButton(),
          //save button
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  // open delete box
  void openDeleteBox(Expense expense) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("New Expense"),
        actions: [
          //cancel button
          _cancelButton(),
          //save button
          _deleteExpenseButton(expense.id),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) => Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: openNewExpenseBox,
            child: const Icon(Icons.add),
          ),
          body: Column(
            children: [
              //GRAPH UI

              //EXPENSE LIST UI
              Expanded(
                child: ListView.builder(
                  itemCount: value.expenses.length,
                  itemBuilder: (context, index) {
                    Expense expense = value.expenses[index];
                    return MyListTile(
                      title: expense.name,
                      trailing: expense.amount.toString(),
                      onEditPressed: (context) {
                        openEditBox(expense);
                      },
                      onDeletePressed: (context) {
                        openDeleteBox(expense);
                      },
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }

  //cancel button method
  Widget _cancelButton() {
    return MaterialButton(
        onPressed: () {
          //pop box
          Navigator.pop(context);
          //clear controllers
          nameController.clear();
          amountController.clear();
        },
        child: const Text('Cancel'));
  }

  //save button method (Create a new Expense)
  Widget _createNewExpenseButton() {
    return MaterialButton(
      onPressed: () async {
        //only save if the fields are not empty
        if (nameController.text.isNotEmpty &&
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);
          //create new expense
          Expense newExpense = Expense(
            name: nameController.text,
            amount: convertStringtoDouble(amountController.text),
            date: DateTime.now(),
          );
          //save to db
          await context.read<ExpenseDatabase>().createNewExpense(newExpense);
          //clear all controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  //save button method (Edit an Expense)
  Widget _editExpenseButton(Expense expense) {
    return MaterialButton(
      onPressed: () async {
        //only save if the fields are not empty
        if (nameController.text.isNotEmpty ||
            amountController.text.isNotEmpty) {
          //pop box
          Navigator.pop(context);
          //create new updated expense
          Expense updatedExpense = Expense(
            name: nameController.text.isNotEmpty
                ? nameController.text
                : expense.name,
            amount: amountController.text.isNotEmpty
                ? convertStringtoDouble(amountController.text)
                : expense.amount,
            date: DateTime.now(),
          );

          //save to db
          //old expense id
          int existingid = expense.id;
          //update expense
          await context
              .read<ExpenseDatabase>()
              .updateExpense(existingid, updatedExpense);
        }
      },
      child: const Text('Save'),
    );
  }

  //save button method (Delete an Expense)
  Widget _deleteExpenseButton(int id) {
    return MaterialButton(
        onPressed: () async {
          // pop box
          Navigator.pop(context);
          // delete expense from db
          await context.read<ExpenseDatabase>().deleteExpense(id);
        },
        child: const Text('Delete'));
  }
}
