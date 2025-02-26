import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MenteeListPage extends StatefulWidget {
  @override
  _MenteeListPageState createState() => _MenteeListPageState();
}

class _MenteeListPageState extends State<MenteeListPage> {
  Future<List<Mentee>> fetchMentees() async {
    final response = await http.get(Uri.parse('http://192.168.0.103:3000/api/admin/mentees'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Mentee.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load mentees');
    }
  }

  Future<void> deleteMentee(String id) async {
    final response = await http.delete(Uri.parse('http://192.168.0.103:3000/api/admin/users/$id'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mentee deleted successfully')));
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete mentee')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentee List'),
      ),
      body: FutureBuilder<List<Mentee>>(
        future: fetchMentees(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No mentees found'));
          } else {
            final mentees = snapshot.data!;
            return ListView.builder(
              itemCount: mentees.length,
              itemBuilder: (context, index) {
                final mentee = mentees[index];
                String fullName = mentee.firstName != null && mentee.lastName != null
                    ? '${mentee.firstName} ${mentee.lastName}'
                    : 'No Name';

                return ListTile(
                  leading: mentee.profilePicture.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(mentee.profilePicture))
                      : CircleAvatar(child: Icon(Icons.person)),
                  title: Text(fullName),
                  subtitle: Text(mentee.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit button
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Navigate to edit page (implement EditMenteePage)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditMenteePage(mentee: mentee),
                            ),
                          );
                        },
                      ),
                      // Delete button
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          deleteMentee(mentee.id); // Call delete function
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class Mentee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String profilePicture;

  Mentee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.profilePicture,
  });

  factory Mentee.fromJson(Map<String, dynamic> json) {
    return Mentee(
      id: json['_id'],
      firstName: json['firstName'] ?? 'No Name',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'] ?? '/uploads/profilePictures/default.png',
    );
  }
}

// EditMenteePage is a simple page to edit mentee details
class EditMenteePage extends StatefulWidget {
  final Mentee mentee;

  EditMenteePage({required this.mentee});

  @override
  _EditMenteePageState createState() => _EditMenteePageState();
}

class _EditMenteePageState extends State<EditMenteePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.mentee.firstName);
    _lastNameController = TextEditingController(text: widget.mentee.lastName);
    _emailController = TextEditingController(text: widget.mentee.email);
  }

  Future<void> updateMentee() async {
    final updatedData = {
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'email': _emailController.text,
    };

    final response = await http.put(
      Uri.parse('http://192.168.0.103:3000/api/admin/users/${widget.mentee.id}'),
      body: json.encode(updatedData),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mentee updated successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update mentee')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Mentee'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter first name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Last Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter last name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateMentee();
                  }
                },
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
