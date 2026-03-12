import '../../data/Delete.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../data/Delete.dart';
import '../../data/Put.dart';
import '../../data/UserModel.dart';
import '../../data/Post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<UserModel> users = [];
  bool isLoading = true;
  String? error;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController jobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  @override
  void dispose() {
    nameController.dispose();
    jobController.dispose();
    super.dispose();
  }

  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      var url = Uri.parse('https://dummyjson.com/users');

      var response = await http.get(url);
      if (response.statusCode == 200) {
        var map = jsonDecode(response.body) as Map<String, dynamic>;
        List result = map['users'];
        setState(() {
          users = result.map((e) => UserModel.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error';
        isLoading = false;
      });
    }
  }

  Future<void> handleDelete(int index) async {
    final user = users[index];
    bool success = await deleteUser(user.id);
    if (success) {
      setState(() {
        users.removeAt(index);
      });
    }
  }

  Future<void> handleAdd() async {
    if (nameController.text.isEmpty || jobController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عبي الحقول')),
      );
      return;
    }
    Post post = Post(name: nameController.text, job: jobController.text);
    bool success = await post.sendData();
    if (success) {
      nameController.clear();
      jobController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('(: User has been added :)')),
      );
    }
  }

  Future<void> handleEdit(int index) async {
    if (nameController.text.isEmpty || jobController.text.isEmpty) return;
    final user = users[index];
    bool success = await putting(nameController.text, jobController.text, user.id);
    if (success) {
      nameController.clear();
      jobController.clear();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Done')),
      );
    }
  }

  void showAddDialog() {
    nameController.clear();
    jobController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: jobController,
              decoration: const InputDecoration(labelText: 'Job'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: handleAdd,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void showEditDialog(int index) {nameController.clear();
  jobController.clear();
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'New Name'),
          ),
          TextField(
            controller: jobController,
            decoration: const InputDecoration(labelText: 'New Job'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => handleEdit(index),
          child: const Text('Save'),
        ),
      ],
    ),
  );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Manager'),
        actions: [
          IconButton(
            onPressed: fetchUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(user.image),
            ),
            title: Text('${user.firstName} ${user.lastName}'),
            subtitle: Text(user.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => showEditDialog(index),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () => handleDelete(index),
                  icon: const Icon(Icons.delete, color: Colors.red),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
