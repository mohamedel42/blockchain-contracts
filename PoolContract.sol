// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./TokenContract.sol";

contract PoolContract is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    EnumerableSet.AddressSet authorized;

    mapping(address => uint256) private balances;

    TokenContract tokenContract;
    IERC20 busdContract;

    bool locked;
    uint256 private collectionId;

    event Claim(address _from, uint256 _amount);

    constructor(uint256 _collectionId) {
        authorized.add(msg.sender);
        collectionId = _collectionId;
    }

    modifier onlyAuthorized() {
        require(authorized.contains(msg.sender), "Access forbidden.");
        _;
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function claim() external {
        require(locked == false, "Pool is locked.");
        require(balances[msg.sender] > 0, "Nothing to claim.");

        busdContract.transfer(msg.sender, balances[msg.sender]);

        emit Claim(msg.sender, balances[msg.sender]);

        delete balances[msg.sender];
    }

    function addBalance(address _to, uint256 _amount) external onlyAuthorized {
        balances[_to] += _amount;
    }

    function setBalance(address _to, uint256 _amount) external onlyAuthorized {
        balances[_to] = _amount;
    }

    function lock() external onlyAuthorized {
        locked = true;
    }

    function unlock() external onlyAuthorized {
        locked = false;
    }

    /*
    Authorization
  */

    function addAuthorized(address _address) external onlyOwner {
        require(!authorized.contains(_address), "Already authorized.");

        authorized.add(_address);
    }

    function removeAuthorized(address _address) external onlyOwner {
        require(authorized.contains(_address), "Unknown address");

        authorized.remove(_address);
    }

    function getAuthorized()
        external
        view
        onlyOwner
        returns (address[] memory)
    {
        return authorized.values();
    }
}
