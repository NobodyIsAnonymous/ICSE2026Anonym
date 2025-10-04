// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
// import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
// import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
// import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./../interface.sol";

// interface IUniswapV2Factory {
//     event PairCreated(address indexed token0, address indexed token1, address pair, uint);
//     function getPair(address tokenA, address tokenB) external view returns (address pair);
// }


interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
        function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
}

contract UniswapBuySellTest is Test {
    IUniswapV2Router02 private uniswapRouter;
    IERC20 private poolTogetherToken;
    IUniswapV2Factory factory;
    IUniswapV2Pair pair;
    address private constant UNISWAP_ROUTER_ADDRESS = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; // Uniswap V2 Router
    address private constant POOL_TOKEN_ADDRESS = 0x0cEC1A9154Ff802e7934Fc916Ed7Ca50bDE6844e;
    address private WETH;

    function setUp() public {
        // Initialize Uniswap Router and PoolTogether Token
        vm.createSelectFork('https://mainnet.infura.io/v3/e87fa958e0744923b862ee55bf1c8100');
        uniswapRouter = IUniswapV2Router02(UNISWAP_ROUTER_ADDRESS);
        poolTogetherToken = IERC20(POOL_TOKEN_ADDRESS);
        WETH = uniswapRouter.WETH();
        factory = IUniswapV2Factory(uniswapRouter.factory());
        pair = IUniswapV2Pair(factory.getPair(WETH, POOL_TOKEN_ADDRESS));
        
        // Give this contract a large amount of ETH for testing
        vm.deal(address(this), 1000 ether); // Assign 1000 ETH for testing purposes
    }

    function testBuyAndSellPoolTogetherToken() public {
        // Record balances before buy
        uint reserve0; 
        uint reserve1;
        uint poolReserve;

        (reserve0, reserve1, ) = pair.getReserves();
        poolReserve = (pair.token0() == WETH) ? reserve1 : reserve0;
        emit log_named_decimal_uint("POOL Token Balance of Uniswap Before Buy", poolReserve, 18);
        emit log_named_decimal_uint("ETH Balance Before Buy", address(this).balance, 18);
        emit log_named_decimal_uint("POOL Token Balance Before Buy", poolTogetherToken.balanceOf(address(this)), 18);
        
        // Step 1: Buy 99% of the PoolTogether tokens in the first block
        buyPoolTokens();
        // Record balances after buy
        (reserve0, reserve1, ) = pair.getReserves();
        poolReserve = (pair.token0() == WETH) ? reserve1 : reserve0;
        emit log_named_decimal_uint("POOL Token Balance of Uniswap After Buy", poolReserve, 18);
        emit log_named_decimal_uint("ETH Balance After Buy", address(this).balance, 18);
        emit log_named_decimal_uint("POOL Token Balance After Buy", poolTogetherToken.balanceOf(address(this)), 18);
        
        // Step 2: Sell all PoolTogether tokens back for ETH in the next block
        vm.roll(block.number + 1); // Move to the next block
        sellPoolTokens();
        // Record balances after sell
        (reserve0, reserve1, ) = pair.getReserves();
        poolReserve = (pair.token0() == WETH) ? reserve1 : reserve0;
        emit log_named_decimal_uint("POOL Token Balance of Uniswap After Sell", poolReserve, 18);
        emit log_named_decimal_uint("ETH Balance After Sell", address(this).balance, 18);
        emit log_named_decimal_uint("POOL Token Balance After Sell", poolTogetherToken.balanceOf(address(this)), 18);
    }

    function buyPoolTokens() internal {
        // Record balances before the transaction
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = POOL_TOKEN_ADDRESS;
        
        uint amountETH = address(this).balance;
        // Get the current reserves of the PoolTogether token
        (uint reserve0, uint reserve1, ) = pair.getReserves();
        uint poolReserve = (pair.token0() == WETH) ? reserve1 : reserve0;
        
        // Calculate 90% of the pool reserve
        uint amountToBuy = (poolReserve * 99) / 100;

        // Execute the swap on Uniswap
        uniswapRouter.swapExactETHForTokens{ value: amountETH }(
            amountToBuy, 
            path, 
            address(this), 
            block.timestamp + 15 minutes
        );

        (reserve0, reserve1, ) = pair.getReserves();
        poolReserve = (pair.token0() == WETH) ? reserve1 : reserve0;
    }

    function sellPoolTokens() internal {
        // Record balances before the transaction
        address[] memory path = new address[](2);
        path[0] = POOL_TOKEN_ADDRESS;
        path[1] = WETH;
        
        uint poolBalance = poolTogetherToken.balanceOf(address(this));
        poolTogetherToken.approve(UNISWAP_ROUTER_ADDRESS, poolBalance);
        
        // Execute the swap back to ETH on Uniswap
        uniswapRouter.swapExactTokensForETH(
            poolBalance, 
            0, // Accept any amount of ETH (for simplicity)
            path, 
            address(this), 
            block.timestamp + 15 minutes
        );
    }

    receive() external payable {}
}
