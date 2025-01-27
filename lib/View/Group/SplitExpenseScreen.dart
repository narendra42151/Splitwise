import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Comman/Colors.dart';
import 'package:splitwise/View/Group/GroupDetails.dart';
import 'package:splitwise/ViewModel/Controller/GroupDetailController.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightPrimaryColor = Color(0xFF2196F3);
  static const Color lightSecondaryColor = Color(0xFF03DAC6);
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightCardBackground = Colors.white;

  // Dark Theme Colors
  static const Color darkPrimaryColor = Color(0xFF3F51B5);
  static const Color darkSecondaryColor = Color(0xFF03DAC6);
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
}

class SplitExpenseScreen extends StatefulWidget {
  final String gpId;
  final double amount;
  final String description;

  const SplitExpenseScreen(
      {Key? key,
      required this.amount,
      required this.description,
      required this.gpId})
      : super(key: key);

  @override
  _SplitExpenseScreenState createState() => _SplitExpenseScreenState();
}

class _SplitExpenseScreenState extends State<SplitExpenseScreen>
    with SingleTickerProviderStateMixin {
  late final Groupdetailcontroller controller;
  final ThemeController themeController = Get.find<ThemeController>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    controller = Get.put(Groupdetailcontroller(groupId: widget.gpId));
    controller.initializeSplitSelection();
    controller.calculateSplitAmount(widget.amount.toString());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackgroundColor
          : AppColors.lightBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        final group = controller.groupDetails.value;
        if (group?.members == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Split Payment',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              AppColors.darkPrimaryColor,
                              AppColors.darkSecondaryColor
                            ]
                          : [
                              AppColors.lightPrimaryColor,
                              AppColors.lightSecondaryColor
                            ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildAmountCard(isDark),
                      const SizedBox(height: 16),
                      _buildMembersList(group, isDark),
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
        backgroundColor:
            isDark ? AppColors.darkPrimaryColor : AppColors.lightPrimaryColor,
        icon: const Icon(Icons.check, color: Colors.white),
        label: const Text(
          'Split',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(bool isDark) {
    return Card(
      elevation: 8,
      color:
          isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '\₹${widget.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(group, bool isDark) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: group.members!.length,
      itemBuilder: (context, index) {
        final member = group.members![index];
        return TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Card(
            color: isDark
                ? AppColors.darkCardBackground
                : AppColors.lightCardBackground,
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Obx(() => CheckboxListTile(
                  checkColor: Colors.white,
                  activeColor: isDark
                      ? AppColors.darkPrimaryColor
                      : AppColors.lightPrimaryColor,
                  value: controller.selectedMembers[index],
                  onChanged: (isSelected) {
                    controller.toggleMemberSelection(index);
                    controller.calculateSplitAmount(widget.amount.toString());
                  },
                  title: Text(
                    member.username ?? "",
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    "\₹${controller.splitAmounts[index].toStringAsFixed(2)}",
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkPrimaryColor
                          : AppColors.lightPrimaryColor,
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
        backgroundColor: const Color.fromARGB(255, 106, 106, 108),
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
            const SizedBox(width: 8),
            const Text("Split Summary"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("Close"),
          ),
          ElevatedButton(
            onPressed: () {
              final totalAmount =
                  double.tryParse(widget.amount.toString()) ?? 0.0;
              controller.calculateSplitAmount(totalAmount.toString());

              controller.createExpense(
                groupId: widget.gpId,
                description: widget.description,
                amount: totalAmount,
                paidBy: controller.groupDetails.value!.createdBy!.id ?? "",
                splitAmong: controller.getSelectedMembersUserIds(),
                splitType: "equal",
                manualSplit: {},
              );

              Get.snackbar(
                "Success",
                "Payment split confirmed",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              Get.offAll(() => GroupDetailsScreen(groupId: controller.groupId));
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }
}
