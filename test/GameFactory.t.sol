// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GameFactory.sol";

contract GameFactoryTest is Test {
    GameFactory gameFactory;

    function setUp() public {
        gameFactory = new GameFactory();
    }

    function testExample() public {
        assertTrue(true);
    }

    function testCreateGame() public {
        assertTrue(gameFactory.numGames() == 0);
        gameFactory.createGame(address(0x123), 1 ether, 7 days);
        assertTrue(gameFactory.numGames() == 1);
    }

    function testGetGames() public {
        gameFactory.createGame(address(0x123), 1 ether, 7 days);
        gameFactory.createGame(address(0x456), 1 ether, 7 days);
        gameFactory.createGame(address(0x789), 1 ether, 7 days);
        address[] memory games = gameFactory.getGames();
        assertTrue(games.length == 3, "Should have 3 games");
    }
}
