/**
    ┌───────────────────────────────────────────────────────────────────────────┐
    |                           --- A BIG THANKS ---                            |
    |           This token is highly inspired by $TURBO. We reduced             |
    |       the token supply and added a token tax to reward Matt Furie,        |
    |  the creator of Pepe the frog and a secret club who will find out later.  | 
    |                             That's so sigma!                              |
    └───────────────────────────────────────────────────────────────────────────┘                                                 
**/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract Sigma is ERC20, ERC20Burnable {
    address public LIQUIDITY_OWNER_ADDRESS;
    address public PEPE_ADDRESS;
    address public SECRET_ADDRESS;

    mapping(address => bool) private _excludedFromFees;

    constructor(address liquidityOwner, address pepe, address secret) ERC20("sigma", "sigma") {
        LIQUIDITY_OWNER_ADDRESS = liquidityOwner;
        PEPE_ADDRESS = pepe;
        SECRET_ADDRESS = secret;
        _mint(LIQUIDITY_OWNER_ADDRESS, 999999999 * 10 ** decimals());
        _excludedFromFees[LIQUIDITY_OWNER_ADDRESS] = true;
    }

    modifier onlyLiquidityOwner() {
        require(_msgSender() == LIQUIDITY_OWNER_ADDRESS, "Only owner.");
        _;
    }

    function setExcludedFromFees(address adr, bool exclude) public onlyLiquidityOwner {
        _excludedFromFees[adr] = exclude;
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        return handleTransfer(_msgSender(), to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        super._spendAllowance(from, _msgSender(), amount);
        return handleTransfer(from, to, amount);
    }

    function handleTransfer(address from, address to, uint256 amount) private returns (bool) {
        uint256 fee = amount / 50;
        if (_excludedFromFees[from] || _excludedFromFees[to]) { 
            fee = 0; 
        }
        if (fee > 0) {
            super._transfer(from, PEPE_ADDRESS, fee/2);
            super._transfer(from, SECRET_ADDRESS, fee/2);
        }
        uint256 transferAmount = amount - fee;
        if (transferAmount > 0) {
            super._transfer(from, to, transferAmount);
            return true;
        }
        return false;
    }
}
