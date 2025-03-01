import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class MentorDetailScreen extends StatefulWidget {
  final dynamic mentor;

  MentorDetailScreen({required this.mentor});

  @override
  _MentorDetailScreenState createState() => _MentorDetailScreenState();
}

class _MentorDetailScreenState extends State<MentorDetailScreen> {
  bool _buttonClicked = false; // Track if the button is clicked

  // Function to confirm selection (verify mentor) and send email
  Future<void> confirmSelection(BuildContext context, String mentorId, String email) async {
    final response = await http.put(
      Uri.parse('http://192.168.0.103:3000/api/admin/verify-mentor/$mentorId'),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mentor verified successfully')),
      );

      // Send email after confirming selection
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: Uri.encodeFull('Subject=Mentor Confirmation&Body=You have been verified as a mentor'),
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        throw 'Could not send email';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to verify mentor')),
      );
    }
  }

  // Function to open URLs externally using url_launcher
  Future<void> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final mentor = widget.mentor;
    bool isVerified = mentor['verified'] ?? false;
    // Base URL for constructing full URLs for images and certificates.
    const String baseUrl = 'http://192.168.0.103:3000/';

    return Scaffold(
      appBar: AppBar(
        title: Text('${mentor['firstName']} ${mentor['lastName']}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mentor profile image with proper URL formatting.
              Image.network(
                Uri.encodeFull('$baseUrl${mentor['profilePicture'].replaceAll('\\', '/')}'),
                errorBuilder: (context, error, stackTrace) {
                  return Text('Error loading profile image');
                },
              ),
              SizedBox(height: 16),
              Text('Full name: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${mentor['firstName']} ${mentor['lastName']}', style: TextStyle(fontWeight: FontWeight.normal)),
              Text('Email: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${mentor['email']}', style: TextStyle(fontWeight: FontWeight.normal)),
              Text('Location: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${mentor['location']}', style: TextStyle(fontWeight: FontWeight.normal)),
              Text('Qualifications: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${mentor['qualifications']}', style: TextStyle(fontWeight: FontWeight.normal)),
              Text('Skills: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${mentor['skills']}', style: TextStyle(fontWeight: FontWeight.normal)),
              Text('Job Title: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${mentor['jobTitle']}', style: TextStyle(fontWeight: FontWeight.normal)),
              Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${mentor['category']}', style: TextStyle(fontWeight: FontWeight.normal)),
              Text('Bio: ', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('${mentor['bio']}', style: TextStyle(fontWeight: FontWeight.normal)),
              SizedBox(height: 10),

              // Field of Study (displayed like Category and Bio)
              if (mentor['fieldOfStudy'] != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Field of Study:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        mentor['fieldOfStudy'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

              // Subjects (displayed like Category and Bio)
              if (mentor['subjects'] != null && mentor['subjects'] is List)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subjects:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        (mentor['subjects'] as List).join(', '),
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 10),

              // Social Links (plain text platform and link below it)
              if (mentor['socialLinks'] != null && mentor['socialLinks'] is List)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Social Links:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ...List<Widget>.from(
                      (mentor['socialLinks'] as List).map((link) {
                        String platform = link['platform'];
                        String url = link['link'];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Platform: $platform', style: TextStyle(fontSize: 16)),
                            SizedBox(height: 4),
                            InkWell(
                              onTap: () async {
                                await openUrl(url);
                              },
                              child: Text(
                                url,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              // Certificates section
              Text('Certificates:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              if (mentor['certificates'] != null && mentor['certificates'].isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: mentor['certificates'].length,
                  itemBuilder: (context, index) {
                    String certPath = mentor['certificates'][index];
                    // Replace backslashes with forward slashes and encode the URL.
                    String fixedCertPath = certPath.replaceAll('\\', '/');
                    String fullUrl = Uri.encodeFull('$baseUrl$fixedCertPath');
                    // Get the file extension.
                    String ext = certPath.split('.').last.toLowerCase();

                    if (ext == 'jpg' || ext == 'jpeg' || ext == 'png') {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Image.network(
                          fullUrl,
                          errorBuilder: (context, error, stackTrace) {
                            return Text('Error loading certificate image');
                          },
                        ),
                      );
                    } else if (ext == 'pdf') {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ElevatedButton(
                          onPressed: () => openUrl(fullUrl),
                          child: Text('View PDF Certificate'),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  },
                )
              else
                Text('No certificates available.'),
              SizedBox(height: 20),
              // Buttons for actions (Confirm Selection and Delete)
              if (!_buttonClicked)
                Column(
                  children: [
                    // Confirm Selection button (Green, small box)
                    if (!isVerified)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Center(  // Wrap the button with Center widget to align it centrally
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _buttonClicked = true; // Hide the button after click
                              });
                              confirmSelection(context, mentor['_id'], mentor['email']);
                            },
                            child: Text(
                              'Confirm Selection',
                              style: TextStyle(color: Colors.white), // White text color
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Green color
                              minimumSize: Size(150, 40), // Smaller size
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8), // Rounded corners
                              ),
                            ),
                          ),
                        ),
                      ),
                    // Delete button (Red, small box)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Center(  // Wrap the button with Center widget to align it centrally
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _buttonClicked = true; // Hide the button after click
                            });
                            // Implement deletion logic if needed.
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red, 
                            minimumSize: Size(160, 40), // Smaller size
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8), // Rounded corners
                            ),
                          ),
                          child: Text(
                            'Delete Mentor',
                            style: TextStyle(color: Colors.white), // White text color
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
