// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./../interface.sol";

// contract ERC20VotesUpgradeable is Initializable, IVotesUpgradeable, ERC20PermitUpgradeable {}

interface IVotesUpgradeable is IERC20{
    /**
     * @dev Returns the current amount of votes that `account` has.
     */
    function getVotes(address account) external view returns (uint256);
    
    /**
     * @dev Returns the amount of votes that `account` had at the end of a past block (`blockNumber`).
     */
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);
    /**
     * @dev Returns the total supply of votes available at the end of a past block (`blockNumber`).
     *
     * NOTE: This value is the sum of all available votes, which is not necessarily the sum of all delegated votes.
     * Votes that have not been delegated are still part of total supply, even though they would not participate in a
     * vote.
     */
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);

    /**
     * @dev Returns the delegate that `account` has chosen.
     */
    function delegates(address account) external view returns (address);
    /**
     * @dev Delegates votes from the sender to `delegatee`.
     */
    function delegate(address delegatee) external;
}

interface IGovernanceContract {
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    ) external returns (uint256 proposalId);
    function getVotes(address account, uint256 blockNumber) external view returns (uint256);
    function castVote(uint256 proposalId, uint8 support) external returns (uint256);
    function votingDelay() external view returns (uint256);
    function votingPeriod() external view returns (uint256);
    function queue(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) external returns(uint256);
    function execute(address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash) external payable returns (uint256);
    function proposalEta(uint256 proposalId) external view returns (uint256);
}

interface IUniswapV3PoolActions {
    function initialize(uint160 sqrtPriceX96) external;
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}

interface IUniswapV3Pool is IUniswapV3PoolActions {
        function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );
}

contract StabilityTokenProposalTest is Test {
    IVotesUpgradeable stabilityToken;
    IGovernanceContract governanceContract;
    IUniswapV3Pool pool;
    IERC20 weth_polygon;
    address deployer;
    address user;
    address rich;
    address rich_weth;

    function setUp() public {
        // Step 1: Set up accounts and contracts
        vm.createSelectFork('https://virtual.polygon.rpc.tenderly.co/e0fd4cbc-2240-44e4-91bb-697191b53b67');
        rich = address(0xbdfff6f6673AB645aF13ef1056E69e195aB728Ad);
        rich_weth = address(0x62ac55b745F9B08F1a81DCbbE630277095Cf4Be1);
        deployer = address(0x88888887C3ebD4a33E34a15Db4254C74C75E5D4A);
        user = address(0x619a4b7E3Dd71B88808c857ef6cb23f65925331F);
        uint8 decimals;

        // Use existing StabilityToken and GovernanceContract addresses
        stabilityToken = IVotesUpgradeable(0x48469a0481254d5945E7E56c1Eb9861429c02f44);
        governanceContract = IGovernanceContract(0x6214Ba4Ce85C0A6F6025b0d63be7d65214463226);
        pool = IUniswapV3Pool(0xE5e70cb76446BEE0053b1EdF22CaDa861c80D51F);
        weth_polygon = IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);

        // Step 2: Transfer initial amount of Stability Token to the user
        decimals = stabilityToken.decimals();
        uint256 initialBalance = 20000 * 10 ** decimals;
        vm.prank(rich); // Set the next call to be from the deployer address
        stabilityToken.transfer(user, initialBalance);
        vm.prank(rich_weth);
        weth_polygon.transfer(user, 10000 * 10 ** 18);

        // a few blocks to let the votes update
        vm.roll(block.number + 2);
    }

    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external {
        vm.prank(user);
        if (amount1Delta > 0) {
            weth_polygon.transfer(msg.sender, uint256(amount1Delta));
        } else {
            weth_polygon.transfer(msg.sender, uint256(-amount1Delta));
        }
    }

    function swap(int256 wethAmount, uint160 priceUpperBound) public{
        // user swap tokens from UniswapV3Pool, token0 = stability, token1 = WETH
        pool.swap(user, false, wethAmount, priceUpperBound, "0x"); // false: token1 for token0, the 4th parameter is the price limit for the swap
    }

    function testSwap() public{
        uint256 pre_stabilityBalance = stabilityToken.balanceOf(user);
        uint256 pre_wethBalance = weth_polygon.balanceOf(user);
        // (uint160 pre_sqrtPriceX96,,,,,,) = pool.slot0();
        swap(50e18, 999121461e19);
        uint256 after_stabilityBalance = stabilityToken.balanceOf(user);
        uint256 after_wethBalance = weth_polygon.balanceOf(user);
        // (uint160 after_sqrtPriceX96,,,,,,) = pool.slot0();
        // uint160 delta_sqrtPriceX96 = after_sqrtPriceX96 - pre_sqrtPriceX96;
        // uint256 delta_stabilityBalance = after_stabilityBalance - pre_stabilityBalance;
        assert(after_stabilityBalance>pre_stabilityBalance);
        assert(after_wethBalance == pre_wethBalance - 50e18);
    }

    function testUserCanCreateProposal() public {
        // Step 3: User checks balance
        uint256 userBalance = stabilityToken.balanceOf(user);
        emit log_named_uint("User initial Stability Token balance", userBalance / 10 ** 18);

        uint256 userVotes = governanceContract.getVotes(user, block.number-1);
        emit log_named_uint("User votes", userVotes);

        vm.prank(user); // Set the next call to be from the user address
        stabilityToken.delegate(user); // Delegate votes to self

        vm.roll(block.number + 1); // Move to the next block
        userVotes = governanceContract.getVotes(user, block.number-1);
        emit log_named_uint("User votes after delegation", userVotes);

        // Step 4: Try to create a proposal
        address[] memory targets = new address[](1);
        targets[0] = address(0x48469a0481254d5945E7E56c1Eb9861429c02f44); // Stability Token address
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = abi.encodeWithSignature("transfer(address,uint256)", user, 100 * 10 ** 18); // Mint 100 tokens to the user
        string memory description = "Mint 100 tokens to the user";

        vm.prank(user); // Set the next call to be from the user address
        uint256 proposalId;
        try governanceContract.propose(targets, values, calldatas, description) returns (uint256 id) {
            proposalId = id;
            emit log_named_uint("Proposal created successfully. Proposal ID:", proposalId);
        } catch Error(string memory reason) {
            emit log(reason);
        }
        
        // Step 5: User casts vote
        vm.roll(block.number + governanceContract.votingDelay()+1); // Move to the start of the voting period
        swap(50e18, 999121461e19);
        vm.prank(user);
        stabilityToken.delegate(user);
        vm.roll(block.number + 1);
        userVotes = governanceContract.getVotes(user, block.number-1);
        emit log_named_uint("User votes after swap", userVotes);


        uint8 support = 1; // 1 for yes, 0 for no
        vm.prank(user); // Set the next call to be from the user address
        governanceContract.castVote(proposalId, support);

        vm.roll(block.number + governanceContract.votingPeriod()); // Move to the end of the voting period
        // generate description hash
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governanceContract.queue(targets, values, calldatas, descriptionHash);

        uint256 proposalEta = governanceContract.proposalEta(proposalId);
        emit log_named_uint("Proposal ETA", proposalEta);
        emit log_named_uint("Current block number", block.number);

        // roll the timestamp to the proposal eta, mindelay=100
        vm.warp(block.timestamp + 101);
        vm.roll(block.number + 3000);
        governanceContract.execute(targets, values, calldatas, descriptionHash); // ERROR: no mint() function in the contract



    }
}
