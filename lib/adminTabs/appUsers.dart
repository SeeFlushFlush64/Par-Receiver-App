import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class AppUsers extends StatefulWidget {
  const AppUsers({super.key});

  @override
  State<AppUsers> createState() => _AppUsersState();
}

class _AppUsersState extends State<AppUsers> {
  void showUserDialog(BuildContext context, String userName, String userUID) {
    Color circularBackgroundColor = Color(0xFF191970);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "User Details",
                style: GoogleFonts.ubuntu(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: circularBackgroundColor,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 20.0,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildDetailsRow("Name:", userName),
              SizedBox(height: 5.0),
              buildDetailsRow("UID:", userUID),
            ],
          ),
        );
      },
    );
  }

  Widget buildDetailsRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label ',
          style: GoogleFonts.ubuntu(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.ubuntu(
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'USERS',
          style: GoogleFonts.ubuntu(
            color: Color(0xFF191970),
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade50,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('userName_email_sign_in')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          final users = snapshot.data!.docs
              .where((user) => user.id != "52ihU8Gw6EbJbd38PYwCnwurj363")
              .toList();

          if (users.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userName = user['Name'];
              final userUID = user['UID'];

              return InkWell(
                onTap: () {
                  showUserDialog(context, userName, userUID);
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    title: Text(
                      userName,
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.bold),
                    ),
                    subtitle: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "UID: ",
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: userUID,
                            style: GoogleFonts.ubuntu(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    leading: Icon(Icons.person, color: Color(0xFF191970)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
