import 'package:flutter/material.dart';
import 'package:admin/services/delete_service.dart';

class DeleteScreen extends StatelessWidget {
  final String userId;

  DeleteScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete User')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await DeleteService().deleteUser(userId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User deleted successfully')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to delete user')),
              );
            }
          },
          child: Text('Delete User'),
        ),
      ),
    );
  }
}
