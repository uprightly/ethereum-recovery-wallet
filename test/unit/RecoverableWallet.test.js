const ReviewGrant = artifacts.require("ReviewGrant");

import ether from 'zeppelin-solidity/test/helpers/ether';
import { advanceBlock } from 'zeppelin-solidity/test/helpers/advanceToBlock';
import { increaseTimeTo, duration } from 'zeppelin-solidity/test/helpers/increaseTime';
import latestTime from 'zeppelin-solidity/test/helpers/latestTime';
import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';

const BigNumber = web3.BigNumber;

require('chai')
  .use(require('chai-as-promised'))
  .use(require('chai-bignumber')(BigNumber))
  .should();

async function getCost(response) {
  const responseTx = await web3.eth.getTransaction(response.tx);
  return responseTx.gasPrice.mul(response.receipt.gasUsed);
}

/**
 * Unit tests for the stake wallet
 */
contract('RecoverableWallet', function ([creator, user, recoveryUser, randomUser]) {

  beforeEach(async function () {
    this.wallet = await RecoverableWallet.new();
    await advanceBlock();
  });

  it("should...", async function () {

  });


});
