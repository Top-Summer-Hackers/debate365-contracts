// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./GameProxy.sol";
import "./interfaces/IGameSingle.sol";

import {Functions, FunctionsClient} from "./dev/functions/FunctionsClient.sol";
// import "@chainlink/contracts/src/v0.8/dev/functions/FunctionsClient.sol"; // Once published
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract Debet365FunctionsConsumer is FunctionsClient, ConfirmedOwner {
    using Functions for Functions.Request;

    event OCRResponse(bytes32 indexed requestId, bytes result, bytes err);

    error InvalidImplementation();
    enum GameType {
        SINGLE,
        MULTIPLE
    }

    bytes32 public latestRequestId;
    bytes public latestResponse;
    bytes public latestError;
    mapping(GameType => address) public implementations;
    mapping(uint256 => address) public games;
    mapping(address => uint256) public gameIds;

    uint256 gameCount = 1;

    constructor(
        address oracle
    ) FunctionsClient(oracle) ConfirmedOwner(msg.sender) {}

    function withdraw(address _token) external onlyOwner {
        IERC20(_token).transfer(
            msg.sender,
            IERC20(_token).balanceOf(address(this))
        );
    }

    function setGameImplementation(
        GameType _type,
        address _impl
    ) external onlyOwner {
        implementations[_type] = _impl;
    }

    function openGame(
        uint256[3] calldata _odds,
        GameType _type,
        address _tokenAddr
    ) external onlyOwner returns (address) {
        address _implementation = implementations[_type];
        if (_implementation == address(0)) {
            revert InvalidImplementation();
        }
        GameProxy game = new GameProxy(_implementation);
        IGameSingle(address(game)).init(_odds, _tokenAddr);

        games[gameCount] = address(game);
        gameIds[address(game)] = gameCount;

        return address(game);
    }

    function _updateOddsOfGame(
        uint256 _gameId,
        uint256[3] memory _odds
    ) internal {
        IGameSingle(games[_gameId]).updateOdds(_odds);
    }

    function getImplementation(GameType _type) external view returns (address) {
        return implementations[_type];
    }

    ///--------------------------CHAINLINK FUNCTIONS-----------------------------------
    ///--------------------------CHAINLINK FUNCTIONS-----------------------------------
    ///--------------------------CHAINLINK FUNCTIONS-----------------------------------

    function executeRequest(
        string calldata source,
        bytes calldata secrets,
        string[] calldata args,
        uint64 subscriptionId,
        uint32 gasLimit
    ) public onlyOwner returns (bytes32) {
        Functions.Request memory req;
        req.initializeRequest(
            Functions.Location.Inline,
            Functions.CodeLanguage.JavaScript,
            source
        );
        if (secrets.length > 0) {
            req.addRemoteSecrets(secrets);
        }
        if (args.length > 0) req.addArgs(args);

        bytes32 assignedReqID = sendRequest(req, subscriptionId, gasLimit);
        latestRequestId = assignedReqID;
        return assignedReqID;
    }

    /**
     * @notice Callback that is invoked once the DON has resolved the request or hit an error
     *
     * @param requestId The request ID, returned by sendRequest()
     * @param response Aggregated response from the user code
     * @param err Aggregated error from the user code or from the execution pipeline
     * Either response or error parameter will be set, but never both
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        (uint256 id, uint256 win, uint256 draw, uint256 loss) = abi.decode(
            response,
            (uint256, uint256, uint256, uint256)
        );
        _updateOddsOfGame(id, [win, draw, loss]);
        emit OCRResponse(requestId, response, err);
    }

    /**
     * @notice Allows the Functions oracle address to be updated
     *
     * @param oracle New oracle address
     */
    function updateOracleAddress(address oracle) public onlyOwner {
        setOracle(oracle);
    }

    function addSimulatedRequestId(
        address oracleAddress,
        bytes32 requestId
    ) public onlyOwner {
        addExternalRequest(oracleAddress, requestId);
    }
}
