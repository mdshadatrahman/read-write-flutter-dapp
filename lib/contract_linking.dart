import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  final String _rpcUrl = 'http://127.0.0.1:7545';
  final String _wsUrl = 'ws://127.0.0.1:7545';
  final String _privateKey = '0x8a0d2f62ed0b9a3b4330b1f15cb2c1f022584f8d90bae2d99db82e7674a8fc53';

  Web3Client? _web3client;
  bool isLoading = false;
  String? _abiCode;
  EthereumAddress? _contractAddress;
  Credentials? _credentials;
  DeployedContract? _contract;
  ContractFunction? _message;
  ContractFunction? _setMessage;
  String? deployedName;

  ContractLinking() {
    setUp();
  }

  setUp() async {
    _web3client = Web3Client(
      _rpcUrl,
      Client(),
      socketConnector: () {
        return IOWebSocketChannel.connect(_wsUrl).cast<String>();
      },
    );
    await getAbi();
    await getCredentials();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    String abiStringFile = await rootBundle.loadString('build/contracts/HelloWorld.json');
    final jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi['abi']);
    _contractAddress = EthereumAddress.fromHex(jsonAbi['networks']['5777']['address']);
  }

  Future<void> getCredentials() async {
    _credentials = EthPrivateKey.fromHex(_privateKey);
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
      ContractAbi.fromJson(_abiCode!, 'HelloWorld'),
      _contractAddress!,
    );
    _message = _contract!.function('message');
    _setMessage = _contract!.function('setMessage');
    getMessage();
  }

  getMessage() async {
    final myMessage = await _web3client!.call(
      contract: _contract!,
      function: _message!,
      params: [],
    );
    deployedName = myMessage[0];
    isLoading = false;
    notifyListeners();
  }

  setMessage(String message) async {
    isLoading = true;
    notifyListeners();
    try {
      await _web3client!.sendTransaction(
        _credentials!,
        Transaction.callContract(
          contract: _contract!,
          function: _setMessage!,
          parameters: [message],
        ),
        chainId: 1337,
      );
      getMessage();
    } catch (e) {
      log(e.toString());
      isLoading = false;
      notifyListeners();
    }
  }
}
