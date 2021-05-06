// SPDX-License-Identifier: GPL-v3
pragma solidity ^0.6.8;

import "./TradeableERC721Token.sol";
import "@chainlink/v0.5/contracts/ChainlinkClient.sol";
import "@chainlink/v0.5/contracts/vendor/Ownable.sol";

contract DelivererToken is TradeableERC721Token, ChainlinkClient, Ownable {
    uint256 constant private ORACLE_PAYMENT = 0 * LINK;
    uint256 _consumption;

    event update();

    constructor(address _proxyRegistryAddress) TradeableERC721Token("Token", "TKN", _proxyRegistryAddress) public Ownable() {
        setChainlinkToken("...");
        setChainlinkOracle("...");
    }

    function getChainlinkToken() public view returns (address) {
        return chainlinkTokenAddress();
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }

    function requestEnergyConsumption(string memory _jobId) public onlyOwner
    {
        Chainlink.Request memory req = buildChainlinkRequest(stringToBytes32(_jobId), address(this), this.RequestEnergyConsumptionFulfilled.selector);
        req.add("get", "...");
        req.add("userID", "id");
        sendChainlinkRequest(req, ORACLE_PAYMENT);

        emit update();
    }

    event RequestEnergyConsumptionFulfilled(
        bytes32 indexed requestId,
        uint256 indexed energyConsumption
    );

    function baseTokenURI() public view returns (string memory) {
        if(_consumption > 10)
            return "ipfs://"; // negative image
        else
            return "ipfs://"; // positive image
    }
}
