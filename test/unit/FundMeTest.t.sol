// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address HUNG_WALLET = makeAddr("hung_wallet"); // Deo duoc gan constant vo address cho nay

    uint256 constant SEND_VALUE = 1e18;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(HUNG_WALLET, 10 ether);
    }

    function testMinimumUSDisFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerisSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 8);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // hey, the next line, should revert!
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(HUNG_WALLET); // The next tx will be sent by this address
        fundMe.fund{value: 1e18}();
        uint256 amountFunded = fundMe.getAddressToAmountFunded(HUNG_WALLET);
        assertEq(amountFunded, 1e18);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(HUNG_WALLET);
        fundMe.fund{value: 1 ether}();
        address funder = fundMe.getFunder(0);
        assertEq(funder, HUNG_WALLET);
    }

    modifier funded() {
        vm.prank(HUNG_WALLET);
        fundMe.fund{value: 1 ether}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(HUNG_WALLET);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act

        //uint256 gasStart = gasleft();
        // vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // uint256 gasEnd = gasleft();
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        // console.log(gasUsed);

        // Assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        // Arrange fund vao hop dong
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // hoax ket hop giua vm.prank() vaf vm.deal()
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act

        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // Assert

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }

    function testCheaperWithdrawFromMultipleFunders() public funded {
        // Arrange fund vao hop dong
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            hoax(address(i), SEND_VALUE); // hoax ket hop giua vm.prank() va vm.deal()
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act

        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        // Assert

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }
}
