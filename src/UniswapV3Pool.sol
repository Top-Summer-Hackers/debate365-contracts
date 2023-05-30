// SPDX-License-Identifier: GPL-2.0-or-later

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol';

contract LiquidityExamples is IERC721Receiver{

    address public tokenA; 
    address public tokenB; 
    uint256 private poolFee; 

    INonfungiblePositionManager public immutable nonfungiblePositionManager;


    // Hardcoded 
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    uint24 public constant poolFee = 3000;

    constructor(address _tokenA, address _tokenB, uint256 _poolFee) {

        tokenA = _tokenA; 
        tokenB = _tokenB; 
        poolFee =_poolFee;





    }

    struct Deposit {
        address owner; // Game contract will be the owner of the deposit
        uint128 liquidity;
        address token0;
        address token1;
    }

    mapping(uint256 => Deposit) public deposits;

    

    constructor(
        INonfungiblePositionManager _nonfungiblePositionManager,
        address _factory,
        address _WETH9
    ) PeripheryImmutableState(_factory, _WETH9) {
        nonfungiblePositionManager = _nonfungiblePositionManager;
    }








}