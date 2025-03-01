import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'mentor_detail_screen.dart';
import 'dart:convert';

class MentorsScreen extends StatefulWidget {
  @override
  _MentorsScreenState createState() => _MentorsScreenState();
}

class _MentorsScreenState extends State<MentorsScreen> {
  late Future<List<dynamic>> mentors;

  @override
  void initState() {
    super.initState();
    mentors = fetchMentors(); // Fetch mentors from the API
  }

  // Fetch mentors from the API
  Future<List<dynamic>> fetchMentors() async {
    final response = await http.get(Uri.parse('http://192.168.0.103:3000/api/admin/mentors'));

    if (response.statusCode == 200) {
      print('Response Body: ${response.body}'); // Debugging
      return json.decode(response.body);
    } else {
      print('Failed to load mentors: ${response.body}'); // Debugging
      throw Exception('Failed to load mentors');
    }
  }

  // Handle delete mentor
 Future<void> deleteMentor(String mentorId) async {
  final response = await http.delete(
    Uri.parse('http://192.168.0.103:3000/api/admin/users/$mentorId'),
  );

  if (response.statusCode == 200) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mentor deleted successfully')));

    setState(() {
      mentors = fetchMentors(); // ✅ Refresh the mentor list after deletion
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete mentor')));
  }
}
  // Handle edit mentor
  Future<void> editMentor(String mentorId) async {
    // Navigate to an edit screen or open a dialog to edit mentor details
    // For now, we just show a dialog for editing purpose
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController = TextEditingController();

        return AlertDialog(
          title: Text('Edit Mentor'),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(hintText: 'Enter new name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (nameController.text.isNotEmpty) {
                  // Send a request to update the mentor details (you can add more fields here)
                  updateMentor(mentorId, nameController.text);
                }
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Update mentor information
  Future<void> updateMentor(String mentorId, String newName) async {
    final response = await http.put(
      Uri.parse('http://192.168.0.103:3000/api/admin/users/$mentorId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'firstName': newName}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mentor updated successfully')));
      setState(() {
        mentors = fetchMentors(); // Refresh the list after update
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update mentor')));
    }
  }

  // Inside _MentorsScreenState:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mentors'),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: mentors,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final mentorList = snapshot.data!;
            return ListView.builder(
              itemCount: mentorList.length,
              itemBuilder: (context, index) {
                final mentor = mentorList[index];

                if (mentor is Map) {
                  String fullName = mentor['firstName'] != null && mentor['lastName'] != null
                      ? '${mentor['firstName']} ${mentor['lastName']}'
                      : 'No Name';
                  String email = mentor['email'] ?? 'No email';
                  String jobTitle = mentor['jobTitle'] ?? 'No job title';
                  String mentorId = mentor['_id'];

                  return ListTile(
                    title: Text(fullName),
                    subtitle: Text('$email, $jobTitle'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Edit button
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            editMentor(mentorId);
                          },
                        ),
                        // Delete button
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteMentor(mentorId);
                          },
                        ),
                        // Eye icon to view the mentor's details
                        IconButton(
                          icon: Icon(Icons.visibility),
                          onPressed: () {
                            // Navigate to mentor details screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MentorDetailScreen(mentor: mentor),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Center(child: Text('Invalid data format'));
                }
              },
            );
          } else {
            return Center(child: Text('No mentors available.'));
          }
        },
      ),
    );
  }
}
