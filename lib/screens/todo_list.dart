import 'dart:convert';

import 'package:flutter/material.dart';

import 'add_page.dart';
import 'package:http/http.dart' as http;

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}
class _TodoListState extends State<TodoList> {

  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Todo List")),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: navigatetoAddPage, label:Text("Add Todo") ),
     body: Visibility(
       visible: isLoading,
       child : Center(child: CircularProgressIndicator()),
       replacement: RefreshIndicator(
         onRefresh: fetchTodo,
         child: Visibility(
           visible: items.isNotEmpty,
           replacement: Center(child: Text('No Todo Item',style: Theme.of(context).textTheme.headlineMedium)),
           child: ListView.builder(
              itemCount: items.length,
              padding: EdgeInsets.all(8),
              itemBuilder: (context , index){
                final item = items[index] as Map;

                final id = item['_id'] as String;

                 return  Card(
                   child: ListTile(
                     title: Text(item['title']),
                     subtitle: Text(item['description']),
                     leading: CircleAvatar(child: Text('${index +1}')),
                     trailing: PopupMenuButton(

                       onSelected: (value){
                         if(value == 'edit'){
                           //Open Edit Page
                           navigatetoEditPage(item);
                         }else if(value == 'delete'){
                           //Delete and remove item
                           deleteById(id);
                         }
                       },
                       itemBuilder: (context){
                         return[
                           PopupMenuItem(child: Text('Edit'),
                             value: 'edit',

                           ),
                           PopupMenuItem(child: Text('Delete'),
                             value: 'delete',
                           ),
                         ];
                       },
                     ),
            ),
                 );
           }),
         ),
       ),
     ),
    );
  }

  Future<void> navigatetoAddPage() async{
   await Navigator.push(context, MaterialPageRoute(builder: (context) => AddTodoPage(),),);
  setState(() {
    isLoading = true;
  });
  fetchTodo();

  }

  Future<void> navigatetoEditPage(Map item) async{
    await Navigator.push(context, MaterialPageRoute(builder: (context) => AddTodoPage(todo: item),),);
    setState(() {
      isLoading = true;
    });
    fetchTodo();

  }

  Future<void>deleteById(String id) async {
    //Delete the item

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);

    final response = await http.delete(uri);

    if(response.statusCode == 200){
    //Remove item from the list
      final filtered = items.where((element) => element['_id'] != id).toList();
          setState(() {
             items = filtered;
          });
    }else{
      //Show error
     showErrorMessage('Deletion Failed');
    }
  }

  Future<void> fetchTodo()async {

    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if(response.statusCode ==200){
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;

      setState(() {
        items = result;
      });
    }
  setState(() {
    isLoading = false;
  });

  }

  void showErrorMessage(String message){
    final snackBar = SnackBar(content: Text(message , style: TextStyle(color: Colors.white),),
      backgroundColor: Colors.redAccent,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
