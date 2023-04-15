// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Game.sol";

contract GameTest is Test {
    address public coordinator;
    uint public stakeAmount = 1 ether;
    Game game;

    function setUp() public {
        game = new Game(coordinator, stakeAmount, 7 days);
    }

    function testExample() public {
        assertTrue(true);
    }

    function testJoinGame() public {
        assertTrue(game.numParticipants() == 0);
        game.joinGame{value: 1 ether}();
        assertTrue(game.numParticipants() == 1);
    }

    function testStartRound() public {
        vm.prank(coordinator);
        game.startRound();
        assertTrue(game.gameActive(), "Game should be active");
        uint roundStartTime = game.roundStartTime();
        assertTrue(roundStartTime > 0, "Round start time should be set");
    }

    function testSubmitSleepScore() public {
        address payable player = payable(address(0x123));
        vm.deal(player, 1 ether);
        vm.prank(player);
        game.joinGame{value: 1 ether}();

        vm.startPrank(coordinator);
        game.startRound();
        game.submitSleepScore(player, 1);

        (, uint score, bool submittedScore) = game.participants(0);
        assertTrue(submittedScore, "Sleep score should be submitted");
        assertTrue(score == 1, "Sleep score should be 1");
    }

    function testRewardsDistribution() public {
        address payable alice = payable(address(0x456));
        address payable bob = payable(address(0x789));
        address payable charlie = payable(address(0xABC));
        vm.deal(alice, 1 ether);
        vm.deal(bob, 1 ether);
        vm.deal(charlie, 1 ether);

        // get everyone to join the game
        assertTrue(address(game).balance == 0, "Game should have no balance");
        vm.prank(alice);
        game.joinGame{value: 1 ether}();
        vm.prank(bob);
        game.joinGame{value: 1 ether}();
        vm.prank(charlie);
        game.joinGame{value: 1 ether}();
        assertTrue(address(game).balance == 3 ether, "Game should have 3 ether");
        assertTrue(game.numParticipants() == 3, "There should be 3 participants");

        // coordinator starts the game
        vm.startPrank(coordinator);
        game.startRound();

        // submitting sleep score
        game.submitSleepScore(alice, 50);
        game.submitSleepScore(bob, 99);
        game.submitSleepScore(charlie, 99);

        // fast forward time
        vm.warp(7 days + 1 seconds);

        // coordinator determines loser
        address loser = game.determineLoserAndRewards();

        // check loser
        assertTrue(loser == alice, "Alice should be the loser");
        assertTrue(address(alice).balance == 0, "Alice should have 0 ether");

        // check balances
        assertTrue(address(bob).balance == 1.5 ether, "Bob should have 1.5 ether");
        assertTrue(address(charlie).balance == 1.5 ether, "Charlie should have 1.5 ether");
        assertTrue(address(game).balance == 0, "Game should have no balance");
    }
}
