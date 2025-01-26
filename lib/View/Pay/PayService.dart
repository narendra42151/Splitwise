import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:splitwise/Models/PayMentModel.dart';
import 'package:splitwise/ViewModel/Controller/PaymentController.dart';
import 'package:upi_pay/api.dart';
import 'package:upi_pay/types/applications.dart';
import 'package:upi_pay/types/discovery.dart';
import 'package:upi_pay/types/meta.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:upi_pay/types/response.dart';

class PaymentScreen extends StatefulWidget {
  final Paymentmodel paymentModel;
  PaymentScreen({required this.paymentModel, super.key});
  @override
  State<StatefulWidget> createState() {
    return _PaymentScreen();
  }
}

class _PaymentScreen extends State<PaymentScreen> {
  String? _upiAddrError;
  late final TextEditingController _upiAddressController;
  late final TextEditingController _amountController;

  final _upiPayPlugin = UpiPay();
  bool _isUpiEditable = false;
  List<ApplicationMeta>? _apps;

  // Static method to load icon
  static Future<Uint8List> _loadIconFromAsset(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    return data.buffer.asUint8List();
  }

  // Add this method to initialize manual apps asynchronously
  Future<List<ApplicationMeta>> _initializeManualUpiApps() async {
    return [
      ApplicationMeta.android(
        UpiApplication(
          appName: 'Super Money',
          androidPackageName: 'money.super.payments',
          discoveryCustomScheme: 'supermoney',
        ),
        await _loadIconFromAsset('assets/SuperMoney.png'),
        1, // priority
        1, // preferredOrder
      ),
      ApplicationMeta.android(
        UpiApplication(
          appName: 'Navi',
          androidPackageName: 'com.naviapp',
          discoveryCustomScheme: 'naviapp',
        ),
        await _loadIconFromAsset('assets/navi.png'),
        1, // priority
        1, // preferredOrder
      ),
    ];
  }

  final _formKey = GlobalKey<FormState>();
  late final Paymentcontroller controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(Paymentcontroller());
    fetchBalance();

    _upiAddressController =
        TextEditingController(text: widget.paymentModel.revicerUpiId);
    _amountController = TextEditingController(text: widget.paymentModel.amout);

    Future.delayed(Duration.zero, () async {
      _apps = await _upiPayPlugin.getInstalledUpiApplications(
          statusType: UpiApplicationDiscoveryAppStatusType.all);

      // Initialize manual apps
      final manualUpiApps = await _initializeManualUpiApps();

      if (_apps != null) {
        for (var manualApp in manualUpiApps) {
          if (!_apps!.any((app) =>
              app.upiApplication.androidPackageName ==
              manualApp.upiApplication.androidPackageName)) {
            _apps!.add(manualApp);
          }
        }
      }

      setState(() {});
    });
  }

  Future<bool> fetchBalance() async {
    String groupId = widget.paymentModel.groupId;
    String expenseId = widget.paymentModel.expenseId;

    // Call the controller's function to fetch balance details
    bool isId = await controller.fetchBalanceId(groupId, expenseId);
    return isId;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _upiAddressController.dispose();
    super.dispose();
  }

  Future<void> _onTap(ApplicationMeta app) async {
    final err = _validateUpiAddress(_upiAddressController.text);
    if (err != null) {
      setState(() {
        _upiAddrError = err;
      });
      return;
    }
    setState(() {
      _upiAddrError = null;
    });

    final transactionRef = Random.secure().nextInt(1 << 32).toString();
    print("Starting transaction with id $transactionRef");
    // bool isId = await fetchBalance();
    // if (isId) {
    final UpiTransactionResponse a = await _upiPayPlugin.initiateTransaction(
      amount: _amountController.text,
      app: app.upiApplication,
      receiverName: widget.paymentModel.receiverName,
      receiverUpiAddress: _upiAddressController.text,
      transactionRef: transactionRef,
      transactionNote: 'UPI Payment',
    );
    handleTransactionResponse(a);
    // } else {
    //   const SnackBar(
    //     content: Text(
    //       'Balance Id Not Found',
    //       style: TextStyle(color: Colors.white),
    //     ),
    //     backgroundColor: Colors.red,
    //     duration: Duration(seconds: 5),
    //   );
    // }
  }

  void handleTransactionResponse(UpiTransactionResponse response) {
    switch (response.status) {
      case UpiTransactionStatus.success:
        onTransactionSuccess(context, response);
        break;
      case UpiTransactionStatus.failure:
        onTransactionFailure(context, response);
        break;
      case UpiTransactionStatus.submitted:
        onTransactionPending(context, response);
        break;
      default:
        onTransactionUnknown(context, response);
    }
  }

  void onTransactionSuccess(
      BuildContext context, UpiTransactionResponse response) {
    controller.updateBalance(true, false); // add balance ID
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction Successful! Transaction ID: ${response.txnId}',
          style: const TextStyle(color: Colors.greenAccent),
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void onTransactionFailure(
      BuildContext context, UpiTransactionResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction Failed! Response Code: ${response.responseCode}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void onTransactionPending(
      BuildContext context, UpiTransactionResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction Submitted and Pending! Transaction ID: ${response.txnId}',
          style: const TextStyle(color: Colors.orangeAccent),
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void onTransactionUnknown(
      BuildContext context, UpiTransactionResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transaction Status Unknown! Raw Response: ${response.rawResponse}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  String? _validateUpiAddress(String value) {
    if (value.isEmpty) {
      return 'UPI VPA is required.';
    }
    if (value.split('@').length != 2) {
      return 'Invalid UPI VPA';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Payment'),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: <Widget>[
            _upiAddressField(),
            if (_upiAddrError != null) _upiAddrErrorWidget(),
            _amountField(),
            if (Platform.isIOS) _submitButton(),
            Platform.isAndroid ? _androidApps() : _iosApps(),
          ],
        ),
      ),
    );
  }

  Widget _upiAddressField() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _upiAddressController,
                enabled: _isUpiEditable,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'address@upi',
                  labelText: 'Receiving UPI Address',
                ),
                validator: (value) {
                  return _validateUpiAddress(value ?? '');
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _upiAddrErrorWidget() {
    return Container(
      margin: const EdgeInsets.only(top: 4, left: 12),
      child: Text(
        _upiAddrError!,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  Widget _amountField() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _amountController,
              readOnly: true,
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Amount',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return Container(
      margin: const EdgeInsets.only(top: 32),
      child: Row(
        children: <Widget>[
          Expanded(
            child: MaterialButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _onTap(_apps![0]);
                }
              },
              child: Text('Initiate Transaction',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.white)),
              color: Theme.of(context).primaryColor,
              height: 48,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _androidApps() {
    return Container(
      margin: const EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Pay Using',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (_apps != null) _appsGrid(_apps!.map((e) => e).toList()),
        ],
      ),
    );
  }

  Widget _iosApps() {
    return Container(
      margin: const EdgeInsets.only(top: 32, bottom: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(bottom: 24),
            child: Text(
              'One of these will be invoked automatically by your phone to '
              'make a payment',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Detected Installed Apps',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (_apps != null) _discoverableAppsGrid(),
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            child: Text(
              'Other Supported Apps (Cannot detect)',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (_apps != null) _nonDiscoverableAppsGrid(),
        ],
      ),
    );
  }

  GridView _discoverableAppsGrid() {
    List<ApplicationMeta> metaList = [];
    _apps!.forEach((e) {
      if (e.upiApplication.discoveryCustomScheme != null) {
        metaList.add(e);
      }
    });
    return _appsGrid(metaList);
  }

  GridView _nonDiscoverableAppsGrid() {
    List<ApplicationMeta> metaList = [];
    _apps!.forEach((e) {
      if (e.upiApplication.discoveryCustomScheme == null) {
        metaList.add(e);
      }
    });
    return _appsGrid(metaList);
  }

  GridView _appsGrid(List<ApplicationMeta> apps) {
    apps.sort((a, b) => a.upiApplication
        .getAppName()
        .toLowerCase()
        .compareTo(b.upiApplication.getAppName().toLowerCase()));
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      physics: const NeverScrollableScrollPhysics(),
      children: apps
          .map(
            (it) => Material(
              key: ObjectKey(it.upiApplication),
              child: InkWell(
                onTap: Platform.isAndroid ? () async => await _onTap(it) : null,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    it.iconImage(48),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      alignment: Alignment.center,
                      child: Text(
                        it.upiApplication.getAppName(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
