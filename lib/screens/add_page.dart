import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:todo_app_with_restapi/screens/todo_list.dart';

class AddTodoPage extends StatefulWidget {

  final Map? todo;
  const AddTodoPage({super.key ,  this.todo});

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();


  bool isEdit = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final todo = widget.todo;

    if(todo != null){
      isEdit = true;

      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descriptionController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text( isEdit ? "Edit Todo" : "Add Todo"),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          TextField(
            controller: titleController,
          //  cursorColor: Colors.greenAccent,
            decoration: InputDecoration(
              hintText: "Title"
            ),

          ),
          SizedBox(height: 20),

          TextField(
            controller:descriptionController ,
           // cursorColor: Colors.greenAccent,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
            hintText: "Description",
            ),
            maxLines: 50,
            minLines: 3,

          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(onPressed: isEdit ? updateData : submitData, child: Text( isEdit ? "Update" : "Submit") ),
          )
        ],
      )
    );
  }

  Future<void> updateData() async {

    final todo = widget.todo;
    if(todo == null){
      print('You can not updated without todo data');
      return;
    }

    final id = todo['_id'];
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri ,
        body: jsonEncode(body),
        headers:{'Content-Type' : 'application/json' }
    );

    if(response.statusCode == 200){
      showSuccessMessage("Updated Successful");
    }else{
      showErrorMessage("Updation failed");
    }
    Navigator.push(context, MaterialPageRoute(builder: (context) =>TodoList() ));
  }



  Future<void> submitData() async {
    //Get the data from form
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };
    //submit data to the server
    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri ,
        body: jsonEncode(body),
      headers:{'Content-Type' : 'application/json' }
    );

  if(response.statusCode == 201){

    titleController.text = ' ';
    descriptionController.text = ' ';

    showSuccessMessage('Creation Success');
  }else{
    showErrorMessage('Creation Failed');

  }

  // show success or fail message based on status
  }

  void showSuccessMessage(String message){
    final snackBar = SnackBar(content: Text(message , style: TextStyle(color:Colors.white ),),
    backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  void showErrorMessage(String message){
    final snackBar = SnackBar(content: Text(message , style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


}
