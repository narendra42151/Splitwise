import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitwise/Models/ExpenseModel.dart';

class SplitRequestCard extends StatefulWidget {
  final ExpenseModel expenseModel;
  SplitRequestCard({required this.expenseModel, super.key});
  @override
  State<StatefulWidget> createState() {
    return _SplitRequestCardState();
  }
}

class _SplitRequestCardState extends State<SplitRequestCard> {
  @override
  Widget build(BuildContext context) {
    final expenseDetails = widget.expenseModel.expenseDetails;
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Split request",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "₹${expenseDetails!.amount}",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                // User avatars
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.purple,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage: AssetImage(
                            'assets/me.png'), // Replace with actual image
                      ),
                    ),
                    Positioned(
                      left: 16,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage: AssetImage(
                            'assets/me.png'), // Replace with actual image
                      ),
                    ),
                    Positioned(
                      left: 32,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundImage: AssetImage(
                            'assets/me.png'), // Replace with actual image
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 12),
                // Progress bar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LinearProgressIndicator(
                        value: 0.25, // 1/4 paid
                        backgroundColor: Colors.grey,
                        color: Colors.blue,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "${expenseDetails.paidBy!.length}/4 paid",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text and icons to the start
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.grey,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "Unpaid · ${_formatTime(expenseDetails.createdAt ?? "")}", // Format time
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ],
                ),
                SizedBox(height: 8), // Add spacing between rows
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0), // Align text with the icon
                  child: Text(
                    "${expenseDetails.description}",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Add your functionality here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Center(
                child: Text(
                  "Pay",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(String createdAt) {
  try {
    // Parse the string into a DateTime object
    DateTime parsedDate = DateTime.parse(createdAt);
    // Format it to "hh:mm a" format
    return DateFormat('hh:mm a').format(parsedDate);
  } catch (e) {
    // If parsing fails, return the original string
    return createdAt;
  }
}
