pragma solidity ^0.8.0;

contract Game {
    struct Participant {
        address participantAddress;
        uint sleepScore;
        bool submittedScore;
    }

    address public coordinator;
    uint public stakeAmount;
    uint public roundDuration;
    uint public roundStartTime;
    uint public numParticipants;
    bool public gameActive;

    Participant[] public participants;
    mapping(address => uint) public participantIndex;

    modifier onlyCoordinator() {
        require(msg.sender == coordinator, "Caller is not the coordinator");
        _;
    }

    constructor(address _coordinator, uint _stakeAmount, uint _roundDuration) {
        coordinator = _coordinator;
        stakeAmount = _stakeAmount;
        roundDuration = _roundDuration;
        gameActive = false;
    }

    function joinGame() public payable {
        require(!gameActive, "Game has already started");
        require(msg.value == stakeAmount, "Incorrect stake amount");
        participants.push(Participant(msg.sender, 0, false));
        participantIndex[msg.sender] = numParticipants;
        numParticipants++;
    }

    function startRound() public onlyCoordinator {
        gameActive = true;
        roundStartTime = block.timestamp;
    }

    function submitSleepScore(
        address participant,
        uint _sleepScore
    ) public onlyCoordinator {
        require(gameActive, "Game is not active");
        require(
            block.timestamp <= roundStartTime + roundDuration,
            "Submission period has ended"
        );
        Participant storage p = participants[participantIndex[participant]];
        require(!p.submittedScore, "Sleep score already submitted");
        p.sleepScore = _sleepScore;
        p.submittedScore = true;
    }

    function determineLoserAndRewards()
        public
        onlyCoordinator
        returns (address)
    {
        require(
            block.timestamp >= roundStartTime + roundDuration,
            "Round still ongoing"
        );
        uint minScoreIndex = 0;

        for (uint i = 1; i < numParticipants; i++) {
            if (
                participants[i].sleepScore <
                participants[minScoreIndex].sleepScore
            ) {
                minScoreIndex = i;
            }
        }

        distributeRewards(minScoreIndex);

        return participants[minScoreIndex].participantAddress;
    }

    function distributeRewards(uint minScoreIndex) public onlyCoordinator {
        uint totalStake = stakeAmount * numParticipants;
        uint payout = totalStake / (numParticipants - 1);
        for (uint i = 0; i < numParticipants; i++) {
            if (i != minScoreIndex) {
                payable(participants[i].participantAddress).transfer(payout);
            }
            participants[i].submittedScore = false;
            participants[i].sleepScore = 0;
        }
    }

    function startNewRound() public onlyCoordinator {
        roundStartTime = block.timestamp;
    }
}
