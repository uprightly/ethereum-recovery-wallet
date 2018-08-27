pragma solidity ^0.4.24;

import "./Recoverable.sol";

/**
 * A basic wallet contract that is recoverable by another party.
 */
contract RecoverableWallet is Recoverable {
  event Sent(address indexed payee, uint256 amount, uint256 balance);
  event Received(address indexed payer, uint256 amount, uint256 balance);


  function () external payable {
    emit Received(msg.sender, msg.value, address(this).balance);
  }

  function sendTo(address _payee, uint256 _amount) public isOwner {
    require(_payee != address(0) && _payee != address(this));
    require(_amount > 0);
    _payee.transfer(_amount);
    emit Sent(_payee, _amount, address(this).balance);
  }
}