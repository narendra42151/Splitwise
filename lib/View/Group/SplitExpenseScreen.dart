import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:splitwise/View/Group/GroupDetails.dart';
import 'package:splitwise/ViewModel/Controller/GroupDetailController.dart';

class SplitExpenseScreen extends StatefulWidget {
  final double amount;
  final String description;

  SplitExpenseScreen({required this.amount, required this.description});

  @override
  _SplitExpenseScreenState createState() => _SplitExpenseScreenState();
}

class _SplitExpenseScreenState extends State<SplitExpenseScreen>
    with SingleTickerProviderStateMixin {
  final Groupdetailcontroller controller = Get.find<Groupdetailcontroller>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    controller.initializeSplitSelection();
    controller.calculateSplitAmount(widget.amount.toString());

    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Lottie.asset(
              'assets/loading_animation.json',
              width: 200,
              height: 200,
            ),
          );
        }

        final group = controller.groupDetails.value;
        if (group?.members == null) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            ),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Split Payment'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.grey[900]!, Colors.grey[800]!]
                          : [Colors.blue[700]!, Colors.blue[500]!],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildAmountCard(),
                      SizedBox(height: 16),
                      _buildMembersList(group),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showSplitSummary,
        icon: Icon(Icons.check),
        label: Text('Split'),
      ),
    );
  }

  Widget _buildAmountCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '\$${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.description,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(group) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: group.members!.length,
      itemBuilder: (context, index) {
        final member = group.members![index];
        return TweenAnimationBuilder(
          duration: Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 4),
            child: Obx(() => CheckboxListTile(
                  value: controller.selectedMembers[index],
                  onChanged: (isSelected) {
                    controller.toggleMemberSelection(index);
                    controller.calculateSplitAmount(widget.amount.toString());
                  },
                  title: Text(member.username ?? ""),
                  subtitle: Text(
                    "\$${controller.splitAmounts[index].toStringAsFixed(2)}",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          ),
        );
      },
    );
  }

  void _showSplitSummary() {
    final splits = controller.getSelectedMembersUserIds();
    if (splits.isEmpty) {
      Get.snackbar(
        "Error",
        "Please select members to split with",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text("Split Summary"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle confirmation
              final totalAmount =
                  double.tryParse(widget.amount.toString()) ?? 0.0;
              controller.calculateSplitAmount(totalAmount.toString());

              // Create the expense
              controller.createExpense(
                groupId: controller.groupId,
                description: widget.description,
                amount: totalAmount,
                paidBy: controller.groupDetails.value!.createdBy!.id ??
                    "", // Use appropriate value
                splitAmong: controller
                    .getSelectedMembersUserIds(), // Pass the list of user IDs
                splitType: "equal", // Or "manual"
                manualSplit: {}, // If manual split is chosen
              );

              Get.snackbar(
                "Success",
                "Payment split confirmed",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              Get.offAll(() => GroupDetailsScreen(
                    groupId: controller.groupId,
                  ));
            },
            child: Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
