import 'package:flutter/material.dart';

class PaymentRequestScreen extends StatelessWidget {
  final List<Map<String, String>> participants = [
    {'name': 'You', 'amount': '₹28.75'},
    {'name': 'Narendra Deshmukh', 'amount': '₹28.75'},
    {'name': 'Rohit Lokhande', 'amount': '₹28.75'},
    {'name': 'Ayush Yadav', 'amount': 'Sent this request'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {},
        ),
        title: Text('Payment Request', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        AssetImage('assets/profile_placeholder.png'),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ayush requested ₹28.75',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('You paid',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey, thickness: 0.5),
            // List Section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Text(
                '4 of 4 paid',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: participants.length,
                itemBuilder: (context, index) {
                  final participant = participants[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.purple,
                      child: Text(
                        participant['name']![0],
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      participant['name']!,
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Text(
                      participant['amount']!,
                      style: TextStyle(
                          color: participant['amount'] == 'Sent this request'
                              ? Colors.grey
                              : Colors.white),
                    ),
                  );
                },
              ),
            ),
            Divider(color: Colors.grey, thickness: 0.5),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total:',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    '₹115',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
