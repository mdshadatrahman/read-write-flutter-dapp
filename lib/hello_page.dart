import 'package:dapp/contract_linking.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HelloPage extends StatefulWidget {
  const HelloPage({super.key});

  @override
  State<HelloPage> createState() => _HelloPageState();
}

class _HelloPageState extends State<HelloPage> {
  TextEditingController inputController = TextEditingController();

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contractLink = Provider.of<ContractLinking>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello Page'),
      ),
      body: contractLink.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Text(contractLink.deployedName ?? ''),
                TextFormField(
                  controller: inputController,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    contractLink.setMessage(inputController.text);
                    inputController.clear();
                  },
                  child: const Text('Set Message'),
                )
              ],
            ),
    );
  }
}
