pragma solidity ^0.8;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract WhitelistContract is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeMath for uint256;

    EnumerableSet.AddressSet authorized;
    EnumerableSet.AddressSet whitelisted;

    constructor () {
        authorized.add(msg.sender);
    }

    modifier onlyAuthorized() {
        require(authorized.contains(msg.sender), "Access forbidden.");
        _;
    }

    function addWallet(address _address) external onlyAuthorized {
        require(!whitelisted.contains(_address), "Already whitelisted.");

        whitelisted.add(_address);
    }

    function removeWallet(address _address) external onlyAuthorized {
        require(whitelisted.contains(_address), "Unknown address.");

        whitelisted.remove(_address);
    }

    function isWhitelisted(address _address) external view returns (bool) {
        return whitelisted.contains(_address);
    }

    /*
        Authorization
    */

    function addAuthorized(address _address) external onlyOwner {
        require(!authorized.contains(_address), "Already authorized.");

        authorized.add(_address);
    }

    function removeAuthorized(address _address) external onlyOwner {
        require(authorized.contains(_address), "Unknown address.");

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
