// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Game} from "./Game.sol";

contract GameFactory {
    address[] public games;
    uint public numGames;

    function createGame(
        address _coordinator,
        uint _stakeAmount,
        uint _roundDuration
    ) public returns (address newContract) {
        address game = address(
            new Game(_coordinator, _stakeAmount, _roundDuration)
        );
        games.push(game);
        numGames++;
        return game;
    }

    function getGames() public view returns (address[] memory) {
        return games;
    }
}
