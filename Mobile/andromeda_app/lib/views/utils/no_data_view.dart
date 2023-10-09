import 'package:flutter/material.dart';

class NoDataView extends StatefulWidget {
  const NoDataView({Key? key}) : super(key: key);

  @override
  State<NoDataView> createState() => _NoDataViewState();
}

class _NoDataViewState extends State<NoDataView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nichts zu zeigen...'),
      ),
      backgroundColor: Colors.grey[100],
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Image(
                    image: AssetImage("assets/images/sad_cat.png"),
                  ),
                 // Positioned(
                 //   bottom: 70,
                 //   left: 0,
                 //   right: 0,
                 //   child: Text(
                 //     'Image by pngtree.com',
                 //     style: TextStyle(fontSize: 10, color: Colors.grey),
                 //     textAlign: TextAlign.center,
                 //   ),
                 // ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Sieht leer aus hier...',
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 130),
            ],
          ),
        ),
      ),
    );
  }
}
