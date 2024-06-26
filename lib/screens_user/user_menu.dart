import 'package:flutter/material.dart';
import 'user_upload.dart';

class MenuWindow extends StatefulWidget {
  const MenuWindow({Key? key}) : super(key: key);

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<MenuWindow> {
  int _selectedIndex = 2;

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => const DisbursementCheque()),
        // );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MenuWindow()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 79, 128, 189),
        toolbarHeight: 77,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'logo.png',
                  width: 60,
                  height: 55,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color.fromARGB(255, 233, 227, 227),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  margin: EdgeInsets.only(right: screenSize.width * 0.02),
                  child: IconButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => NotificationScreen()),
                      // );
                    },
                    icon: const Icon(
                      Icons.notifications,
                      size: 24, // Adjust size as needed
                      color: Color.fromARGB(255, 233, 227, 227),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.person,
                    size: 24, // Adjust size as needed
                    color: Color.fromARGB(255, 233, 227, 227),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 255, 255),
              Color.fromARGB(255, 255, 255, 255),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: screenSize.height * 0.05), // Add space at the top
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              width: screenSize.width * 0.4,
              height: screenSize.height * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenSize.width *
                    0.4 *
                    0.5), // Radius half of the container width
                border: Border.all(
                  color: const Color.fromARGB(255, 79, 128, 189),
                  width: screenSize.width * 0.0158,
                ),
              ),
              child: Icon(
                Icons.person,
                size: screenSize.width *
                    0.4 *
                    0.4, // Icon size relative to container width
              ),
            ),
            SizedBox(
                height: screenSize.height *
                    0.03), // Space between container and buttons
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle_outlined),
                              SizedBox(width: 10),
                              Text(
                                'Approval',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.fact_check_outlined),
                              SizedBox(width: 5),
                              Text(
                                'Transmittal',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.upload_file),
                              SizedBox(width: 5),
                              Text(
                                'Document Uploading',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.fingerprint_rounded),
                              SizedBox(width: 5),
                              Text(
                                'Biometrics',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.security),
                              SizedBox(width: 5),
                              Text(
                                'Change Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    ElevatedButton(
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.login_outlined),
                              SizedBox(width: 5),
                              Text(
                                'Log out',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Color.fromARGB(255, 79, 128, 189),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file_outlined),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz),
            label: 'No Support',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_sharp),
            label: 'Menu',
          ),
        ],
      ),
    );
  }
}
