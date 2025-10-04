// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./../interface.sol";
// import "https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Pool.sol";
// import "https://github.com/Uniswap/v3-core/blob/main/contracts/interfaces/IUniswapV3Factory.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IUniswapV3Pool 
{
    function slot0() external view returns (uint160 sqrtPriceX96, int24 tick, uint16 observationIndex, uint16 observationCardinality, uint16 observationCardinalityNext, uint8 feeProtocol, bool unlocked);
    function swap(address recipient, bool zeroForOne, int256 amountSpecified, uint160 sqrtPriceLimitX96, bytes calldata data) external;
    function token0() external view returns (address);
    function token1() external view returns (address);
}


contract UniswapBuySellTest is Test {
    receive() external payable {}
    IERC20 private poolTogetherToken;
    address private constant POOL_ADDRESS = 0xff2bDF3044C601679dEde16f5D4a460B35cebfeE; // Uniswap V3 Pool address
    address private constant POOL_TOKEN_ADDRESS = 0x0cEC1A9154Ff802e7934Fc916Ed7Ca50bDE6844e;
    address private WETH;

    function setUp() public {
        // Initialize PoolTogether Token
        vm.createSelectFork('https://mainnet.infura.io/v3/e87fa958e0744923b862ee55bf1c8100');
        poolTogetherToken = IERC20(POOL_TOKEN_ADDRESS);
        WETH = IUniswapV3Pool(POOL_ADDRESS).token1(); // Assuming WETH is token1
        
        // Give this contract a large amount of ETH for testing
        vm.deal(address(this), 1_000e18); // Assign 1,000 ETH for testing purposes
    }

    function testBuyAndSellPoolTogetherToken() public {
        // Record balances before buy
        emit log_named_decimal_uint("ETH Balance Before Buy", address(this).balance, 18);
        emit log_named_decimal_uint("POOL Token Balance Before Buy", poolTogetherToken.balanceOf(address(this)), 18);
        
        // Step 1: Buy 90% of the PoolTogether tokens in the first block
        buyPoolTokens();
        // Record balances after buy
        emit log_named_decimal_uint("ETH Balance After Buy", address(this).balance, 18);
        emit log_named_decimal_uint("POOL Token Balance After Buy", poolTogetherToken.balanceOf(address(this)), 18);
        
        // Step 2: Sell all PoolTogether tokens back for ETH in the next block
        vm.roll(block.number + 1); // Move to the next block
        sellPoolTokens();
        // Record balances after sell
        emit log_named_decimal_uint("ETH Balance After Sell", address(this).balance, 18);
        emit log_named_decimal_uint("POOL Token Balance After Sell", poolTogetherToken.balanceOf(address(this)), 18);
    }

    function buyPoolTokens() internal {
        // Record pool token reserve before buy
        IUniswapV3Pool pool = IUniswapV3Pool(POOL_ADDRESS);
        (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();
        emit log_named_decimal_uint("Pool Token Reserve Before Buy", uint128(sqrtPriceX96), 18);

        // Execute the swap on Uniswap V3
        bool zeroForOne = WETH < POOL_TOKEN_ADDRESS;
        int256 amountSpecified = int256(address(this).balance);
        uint160 sqrtPriceLimitX96 = 0;

        pool.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        // Record pool token reserve after buy
        (sqrtPriceX96, tick,,,,,) = pool.slot0();
        emit log_named_decimal_uint("Pool Token Reserve After Buy", uint128(sqrtPriceX96), 18);
    }

    function sellPoolTokens() internal {
        // Record pool token reserve before sell
        IUniswapV3Pool pool = IUniswapV3Pool(POOL_ADDRESS);
        (uint160 sqrtPriceX96, int24 tick,,,,,) = pool.slot0();
        emit log_named_decimal_uint("Pool Token Reserve Before Sell", uint128(sqrtPriceX96), 18);

        // Execute the swap on Uniswap V3
        uint poolBalance = poolTogetherToken.balanceOf(address(this));
        poolTogetherToken.approve(POOL_ADDRESS, poolBalance);
        bool zeroForOne = POOL_TOKEN_ADDRESS < WETH;
        int256 amountSpecified = int256(poolBalance);
        uint160 sqrtPriceLimitX96 = 0;

        pool.swap(
            address(this),
            zeroForOne,
            amountSpecified,
            sqrtPriceLimitX96,
            ""
        );

        // Record pool token reserve after sell
        (sqrtPriceX96, tick,,,,,) = pool.slot0();
        emit log_named_decimal_uint("Pool Token Reserve After Sell", uint128(sqrtPriceX96), 18);
    }
}
