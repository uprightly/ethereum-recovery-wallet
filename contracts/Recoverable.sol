pragma solidity ^0.4.24;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract Recoverable is Ownable{
  address private recoverer_;
  uint256 private recoveryTimeRequired_;
  uint256 private timeOfRecovery_;
  address public recoveryAddress;

  event RecovererChanged(
    address indexed owner,
    address indexed newRecoverer
  );
  event RecoveryStarted(
    address indexed recoveryAddress,
    address indexed recoverer_,
    uint256 timeOfRecovery
  );
  event Recovered(
    address indexed previousOwner,
    address indexed newOwner
  );
  event OwnerBlockedRecovery(address indexed owner);
  event Sent(address indexed payee, uint256 amount, uint256 balance);

  /**
   * Check that a function is called by the recoverer_
   */
  modifier isRecoverer() {
    require(msg.sender == recoverer_);
    _;
  }

  /**
   * Creates a recoverable contract with required recovery time set by
   * the original sender
   */
  constructor(uint256 _recoveryTime) public {
    recoveryTimeRequired_ = _recoveryTime;
  }

  /**
   * The owner can set a new recoverer when they wish
   */
  function setRecoverer(address _newRecoverer) public onlyOwner {
    require(_newRecoverer != owner);
    emit RecovererChanged(owner, _newRecoverer);
    recoverer_ = _newRecoverer;
  }

  function recoverer() public view returns(address) {
    return recoverer_;
  }

  function recoveryTimeRequired() public view returns(uint256) {
    return recoveryTimeRequired_;
  }

  function timeOfRecovery() public view returns(uint256) {
    return timeOfRecovery_;
  }

  /**
   * Owner can remove the recoverer
   */
  function removeRecoverer() public onlyOwner {
    recoverer_ = address(0);
  }

  /**
   * Recoverer can start a recovery by announcing it.
   * Recoverer will have to wait for the recovery time required.
   */
  function announceRecovery(address _newAddress) public isRecoverer {
    require(recoveryTimeLapsed());
    timeOfRecovery_ = block.timestamp;
    recoveryAddress = _newAddress;
    emit RecoveryStarted(recoveryAddress, recoverer_, timeOfRecovery_);
  }

  /**
   * Owner can block recovery if they deem it illegitimate
   */
  function blockRecovery() public onlyOwner {
    emit OwnerBlockedRecovery(owner);
    timeOfRecovery_ = 0;
  }

  /**
   * Once reverty time has lapsed, a recoverer may transfer ownership
   * to themselves
   */
  function recoverContract() public isRecoverer {
    require(recoveryTimeLapsed());
    emit Recovered(owner, recoverer_);
    _sendTo(recoveryAddress, address(this).balance);
    timeOfRecovery_ = 0;
  }

  /**
   * Check for whether recovery time has lapsed
   */
  function recoveryTimeLapsed() internal view returns (bool) {
    return block.timestamp >= timeOfRecovery_ + recoveryTimeRequired_;
  }

  function _sendTo(address _payee, uint256 _amount) private {
    require(_payee != address(0) && _payee != address(this));
    require(_amount > 0);
    _payee.transfer(_amount);
    emit Sent(_payee, _amount, address(this).balance);
  }
}
