// SPDX-License-Identifier: MIT
pragma solidity >=0.5.9 <0.9.0;

contract HelloWorld {
    string public message;

    constructor() {
        message = "Hello World!";
    }

    function setMessage(string memory _message) public {
        message = _message;
    }
}
