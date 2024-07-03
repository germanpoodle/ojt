import 'package:flutter/material.dart';

class Success extends StatelessWidget {
  const Success({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
       height: double.infinity,
       width: double.infinity,
       decoration: const BoxDecoration(
         gradient: LinearGradient(
           colors: [
             Color.fromARGB(255, 112, 23, 184),
             Color(0xff281537),
           ]
         )
       ),
       child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        
        children: [
          Text(' ')
        ],
        )
       ),
      );
  }
}