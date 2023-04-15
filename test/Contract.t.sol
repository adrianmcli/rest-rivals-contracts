// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Game.sol";

contract ContractTest is Test {
    address public coordinator;
    Game game;

    function setUp() public {
        game = new Game(coordinator, 1, 7 days);
    }

    function testExample() public {
        assertTrue(true);
    }

    function testJoinGame() public {
        assertTrue(game.numParticipants() == 0);
        game.joinGame{value: 1}();
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
        vm.prank(tx.origin);
        game.joinGame{value: 1}();
        vm.prank(coordinator);
        game.startRound();
        game.submitSleepScore(1);
        (, , bool submittedScore) = game.participants(0);
        assertTrue(submittedScore, "Sleep score should be submitted");
    }
}
