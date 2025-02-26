import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Update the path as needed
import 'mentors_screen.dart';  
import 'mentees_screen.dart';  
import 'dart:convert';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int mentorCount = 0;
  int menteeCount = 0;

  @override
  void initState() {
    super.initState();
    getUserCounts();
  }

  // Function to fetch the user counts (mentors and mentees)
  Future<void> getUserCounts() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.0.103:3000/api/admin/user-count'));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          mentorCount = data['mentorCount'];
          menteeCount = data['menteeCount'];
        });
      } else {
        throw Exception('Failed to load user counts');
      }
    } catch (e) {
      print('Error fetching user counts: $e');
    }
  }

  // Function to handle mentor deletion and then refresh counts
  Future<void> deleteMentor(String mentorId) async {
    try {
      final response = await http.delete(Uri.parse('http://192.168.0.103:3000/api/admin/users/$mentorId'));
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mentor deleted successfully')));
        getUserCounts();  // Refresh mentor count after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete mentor')));
      }
    } catch (e) {
      print('Error deleting mentor: $e');
    }
  }

  // Function to handle mentor edit and then refresh counts
  Future<void> editMentor(String mentorId) async {
    // Open a dialog or navigate to an edit screen, and after editing:
    // Once edited, call `getUserCounts()` to refresh the count
    getUserCounts();  // Refresh counts after editing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Display mentor count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mentors: $mentorCount',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Button to view mentors
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the mentors screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MentorsScreen()),
                    );
                  },
                  child: Text('View Mentors'),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Display mentee count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mentees: $menteeCount',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                // Button to view mentees
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the mentees screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MenteeListPage()),
                    );
                  },
                  child: Text('View Mentees'),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
