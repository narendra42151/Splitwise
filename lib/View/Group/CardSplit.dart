import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:splitwise/Models/ExpenseModel.dart';

class SplitRequestCard extends StatelessWidget {
  final ExpenseModel expenseModel;
  final VoidCallback onTap;

  const SplitRequestCard({
    required this.expenseModel,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final expenseDetails = expenseModel.expenseDetails;
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isDark ? Colors.grey[800] : Colors.white,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.grey[900]!, Colors.grey[800]!]
                : [Colors.white, Colors.grey[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Split Request",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(
                    Icons.more_vert,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Amount Section
              Text(
                "₹${expenseDetails!.amount}",
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),

              // User & Progress Section
              Row(
                children: [
                  // Stacked Avatars
                  _buildStackedAvatars(),
                  const SizedBox(width: 16),

                  // Progress Indicator
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value:
                                (expenseModel.expenseDetails!.paidBy!.length) /
                                    (expenseModel
                                        .expenseDetails!.splitAmong!.length),
                            backgroundColor:
                                isDark ? Colors.grey[700] : Colors.grey[300],
                            color: Colors.blue,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${expenseDetails.paidBy!.length}/${expenseDetails.splitAmong!.length} Paid",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Details Section
              _buildDetailsRow(isDark, expenseDetails),
              const SizedBox(height: 16),

              // Pay Button
              _buildPayButton(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStackedAvatars() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.purple.shade200,
          child: const CircleAvatar(
            radius: 18,
            backgroundImage: AssetImage('assets/me.png'),
          ),
        ),
        Positioned(
          left: 24,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green.shade200,
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/me.png'),
            ),
          ),
        ),
        Positioned(
          left: 48,
          child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue.shade200,
            child: const CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/me.png'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsRow(bool isDark, dynamic expenseDetails) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: isDark ? Colors.white54 : Colors.black54,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  "Pending · ${_formatTime(expenseDetails.createdAt ?? "")}",
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Text("${expenseDetails.description}",
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                )),
          ],
        ),
        IconButton(
          onPressed: () {
            onTap();
          },
          icon: Icon(
            Icons.arrow_forward_ios,
            color: isDark ? Colors.white54 : Colors.black54,
            size: 16,
          ),
        )
      ],
    );
  }

  Widget _buildPayButton(bool isDark) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.payment, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            "Pay Now",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// Existing time formatting function
String _formatTime(String createdAt) {
  try {
    DateTime parsedDate = DateTime.parse(createdAt);
    return DateFormat('hh:mm a').format(parsedDate);
  } catch (e) {
    return createdAt;
  }
}
