// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interactions.s.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract InteractionTest is Test {
    FundMe public fundMe;

    address HUNG_WALLET = makeAddr("hung_wallet"); // Deo duoc gan constant vo address cho nay

    uint256 constant SEND_VALUE = 1e18;
    uint256 constant STARTING_VALUE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(HUNG_WALLET, STARTING_VALUE);
    }

    function testUserCanFundAndWithdraw() public {
        uint256 preUserBalance = address(HUNG_WALLET).balance;
        uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

        vm.prank(HUNG_WALLET);
        fundMe.fund{value: SEND_VALUE}();

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        uint256 afterUserBalance = address(HUNG_WALLET).balance;
        uint256 afterOwnerBalance = address(fundMe.getOwner()).balance;

        assert(address(fundMe).balance == 0);
        assertEq(afterUserBalance + SEND_VALUE, preUserBalance);
        assertEq(preOwnerBalance + SEND_VALUE, afterOwnerBalance);
    }
}
