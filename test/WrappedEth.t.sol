// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2, stdError} from "forge-std/Test.sol";
import {WrappedEth} from "../src/WrappedEth.sol";

contract WrappedEthTest is Test {
    WrappedEth public weth;
    address user1;
    event Deposit(address _address, uint _value);
    event Withdraw(address _address, uint _value);

    function setUp() public {
        weth = new WrappedEth();
        user1 = makeAddr("user1");
    }

    function testDeposit() public {
        startHoax(user1, 5 ether);
        uint256 contractBalanceBefore = address(weth).balance;
        uint256 user1BalanceBefore = weth.balanceOf(user1);

        // 測項 3: deposit 應該要 emit Deposit event
        vm.expectEmit(false, false, false, false);
        emit Deposit(address(user1), 1 ether);

        // address(weth).call{value: 1 ether}("deposit()");
        address(weth).call{value: 1 ether}("");

        uint256 contractBalanceAfter = address(weth).balance;
        uint256 user1BalanceAfter = weth.balanceOf(user1);

        // 測項 1: deposit 應該將與 msg.value 相等的 ERC20 token mint 給 user
        assertEq(user1BalanceAfter - user1BalanceBefore, 1 ether);

        // 測項 2: deposit 應該將 msg.value 的 ether 轉入合約
        assertEq(contractBalanceAfter - contractBalanceBefore, 1 ether);

        vm.stopPrank();
    }

    function testWithdraw() public {
        // 給user1 5 eth 並且開始prank
        startHoax(user1, 5 ether);
        // 給 user1 , 3顆 weth
        deal(address(weth), user1, 3 ether);
        // 給 weth 100eth
        deal(address(weth), 100 ether);

        uint256 user1BalanceOfWETH_Before = weth.balanceOf(user1);
        uint256 user1BalabceOfETH_Before = user1.balance;

        // 測項 6: withdraw 應該要 emit Withdraw event
        vm.expectEmit(false, false, false, false, address(weth));
        emit Withdraw(address(user1), 1 ether);

        weth.withdraw(1 ether);
        // address(weth).call(
        //     abi.encodeWithSignature("withdraw(uint256)", 1 ether)
        // );

        uint256 user1BalanceOfWETH_After = weth.balanceOf(user1);
        uint256 user1BalabceOfETH_After = user1.balance;

        vm.expectRevert(stdError.arithmeticError);
        // 測項 4: withdraw 應該要 burn 掉與 input parameters 一樣的 weth token
        assertEq(user1BalanceOfWETH_After - user1BalanceOfWETH_Before, 1 ether);

        // 測項 5: withdraw 應該將 burn 掉的 weth 換成 ether 轉給 user
        assertEq(user1BalabceOfETH_After - user1BalabceOfETH_Before, 1 ether);

        vm.stopPrank();
    }

    function testTransfer() public {
        // 測項 7: transfer 應該要將 weth token 轉給別人

        address user2 = makeAddr("user2");
        // 設定 user1 3顆weth
        deal(address(weth), user1, 3 ether);
        // 設定 user2 0顆weth
        deal(address(weth), user2, 0 ether);

        vm.startPrank(user1);

        weth.transfer(user2, 2 ether);
        // address(weth).call(
        //     abi.encodeWithSignature("transfer(address,uint256)", user2, 2 ether)
        // );

        assertEq(weth.balanceOf(user1), 1 ether);
        assertEq(weth.balanceOf(user2), 2 ether);

        vm.stopPrank();
    }

    function testApprove() public {
        address spender = makeAddr("spender");
        address user2 = makeAddr("user2");

        deal(address(weth), user1, 10 ether);
        deal(address(weth), spender, 0 ether);
        deal(address(weth), user2, 0 ether);

        vm.startPrank(user1);

        weth.approve(spender, 8 ether);
        // address(weth).call(
        //     abi.encodeWithSignature(
        //         "approve(address,uint256)",
        //         spender,
        //         8 ether
        //     )
        // );

        // 測項 8: approve 應該要給他人 allowance
        uint256 allowance = weth.allowance(user1, spender);
        assertEq(allowance, 8 ether);

        vm.stopPrank();

        vm.startPrank(spender);

        uint256 balanceOfUser2_Before = weth.balanceOf(user2);

        weth.transferFrom(user1, user2, 3 ether);
        // address(weth).call(
        //     abi.encodeWithSignature(
        //         "transferFrom(address,address,uint256)",
        //         user1,
        //         user2,
        //         3 ether
        //     )
        // );
        // 測項 9: transferFrom 應該要可以使用他人的 allowance
        uint256 balanceOfUser2_After = weth.balanceOf(user2);
        assertEq(balanceOfUser2_After - balanceOfUser2_Before, 3 ether);

        // 測項 10: transferFrom 後應該要減除用完的 allowance
        assertEq(weth.allowance(user1, spender), 5 ether);
    }
}
