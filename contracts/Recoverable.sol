pragma solidity ^0.4.24;


contract Recoverable {
  address public owner_;
  address private recoverer_;
  uint256 private recoveryTimeRequred_;
  uint256 private timeOfRecovery_;

  event OwnerChanged(
    address indexed previousOwner,
    address indexed newOwner
  );
  event RecovererChanged(
    address indexed owner_,
    address indexed newRecoverer
  );
  event RecoveryStarted(
    address indexed owner_,
    address indexed heir,
    uint256 timeOfRecovery
  );
  event Recovered(
    address indexed previousOwner,
    address indexed newOwner
  );
  event OwnerBlockedRecovery(address indexed owner_);

  /**
   * Check that a function is called by the owner_
   */
  modifier isOwner() {
    require(msg.sender == owner_);
    _;
  }

  /**
   * Check that a function is called by the recoverer_
   */
  modifier isRecoverer() {
    require(msg.sender == recoverer_);
    _;
  }

  /**
   * Creates a recoverable contract with owner set to the original sender and
   * required recovery time set by the original sender
   */
  constructor(uint256 _recoveryTime) public {
    owner_ = msg.sender;
    recoveryTimeRequred_ = _recoveryTime;
  }

  /**
   * The owner can set a new recoverer when they wish
   */
  function setRecoverer(address _newRecoverer) public isOwner {
    require(_newRecoverer != owner_);
    emit RecovererChanged(owner_, _newRecoverer);
    recoverer_ = _newRecoverer;
  }

  function recoverer() public view returns(address) {
    return recoverer_;
  }

  function recoveryTimeRequred() public view returns(uint256) {
    return recoveryTimeRequred_;
  }

  function timeOfRecovery() public view returns(uint256) {
    return timeOfRecovery_;
  }

  /**
   * Owner can remove the recoverer
   */
  function removeRecoverer() public isOwner {
    recoverer_ = address(0);
  }

  /**
   * Recoverer can start a recovery by announcing it.
   * Recoverer will have to wait for the recovery time required.
   */
  function announceRecovery() public isOwner {
    require(recoveryTimeLapsed());
    emit RecoveryStarted(owner_, recoverer_, timeOfRecovery_);
    timeOfRecovery_ = block.timestamp;
  }

  /**
   * Owner can block recovery if they deem it illegitimate
   */
  function blockRecovery() public isOwner {
    emit OwnerBlockedRecovery(owner_);
    timeOfRecovery_ = 0;
  }

  /**
   * Once reverty time has lapsed, a recoverer may transfer ownership
   * to themselves
   */
  function recoverContract() public isRecoverer {
    require(recoveryTimeLapsed());
    emit Recovered(owner_, recoverer_);
    transferOwnership(recoverer_);
    timeOfRecovery_ = 0;
  }

  /**
   * Check for whether recovery time has lapsed
   */
  function recoveryTimeLapsed() internal view returns (bool) {
    return block.timestamp <= timeOfRecovery_ + recoveryTimeRequred_;
  }

  /**
   * The owner can transfer ownership of the contract
   */
  function transferOwnership(address _newOwner) public isOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * The transfer mechanism
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnerChanged(owner_, _newOwner);
    owner_ = _newOwner;
  }
}
