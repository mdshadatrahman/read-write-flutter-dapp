import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';

class ContractLinking extends ChangeNotifier {
  final String _rpcUrl = 'http://127.0.0.1:7545';
  final String _wsUrl = 'ws://127.0.0.1:7545';
  final String _privateKey = '0x31c2c34e07010069e01ced3399304634d3d2befe6d97558e888b4c34f5d6482e';

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
    _abiCode = jsonAbi['abi'];
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
    await _web3client!.sendTransaction(
      _credentials!,
      Transaction.callContract(
        contract: _contract!,
        function: _setMessage!,
        parameters: [message],
      ),
    );
    getMessage();
  }
}
