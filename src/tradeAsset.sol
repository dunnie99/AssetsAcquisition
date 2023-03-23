// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";
import "./property.sol";
import "./IToken.sol";

import "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract tradeAssets {
    //function events
    event PropertyListed(uint256 indexed propertyId, address indexed owner);
    event PropertySold(uint256 indexed propertyId, address indexed newOwner);

    //chainlink price feed addresses.
    AggregatorV3Interface ETHLINK = AggregatorV3Interface(0xDC530D9457755926550b59e8ECcdaE7624181557);
    AggregatorV3Interface ETHAAVE = AggregatorV3Interface(0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012);
    AggregatorV3Interface ETHDAI = AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);
    AggregatorV3Interface ETHUSDT = AggregatorV3Interface(0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46);
    AggregatorV3Interface ETHUNI = AggregatorV3Interface(0xD6aA3D25116d8dA79Ea0246c4826EB951872e02e);
    
    //Accepted tokens addresses
    IToken internal LINK;
    IToken internal AAVE;
    IToken internal DAI;
    IToken internal USDT;
    IToken internal UNI;

    uint256 public tokenDecimal;
    address public moderator;

    //Property info struct
    struct Property{
        bool forSale;
        address owner;
        string name;
        string description;
        string location;
        uint256 price;

    }

    //mapping of property ID to struct that contains property info
    mapping(uint256 => Property) public properties;
    mapping(uint256 => bool) idUsed;

    //Array of listed property IDs
    uint256[] public propertyIds;


    constructor(){
        tokenDecimal = 1e8;
        LINK = IToken(0x514910771AF9Ca656af840dff83E8264EcF986CA);
        AAVE = IToken(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
        DAI = IToken(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        USDT = IToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        UNI = IToken(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);

                moderator = msg.sender;
    }


    modifier onlyOwner {
        require(msg.sender == moderator, "Not a moderator");
        _;
        
    }

    modifier isValidID(uint _propertyId) {
        require((idUsed[_propertyId]), "INVALID ID");
        _;
    }

    function getPrice(AggregatorV3Interface _token2swap, int _decimal) public view returns (int){
    (, int256 answer, , , ) = _token2swap.latestRoundData();

    return (answer / _decimal); 
    }

    //int ethPrice = getPrice(ETHUSD, tokenDecimal);

    function listProperty(uint256 _propertyId, string memory _propertyName, string memory _propertyDescription, string memory _propertyLocation) payable public {
        require(msg.value > 0, "Insufficient Fund");
        require(idUsed[_propertyId] == false, "ID already taken");
        idUsed[_propertyId] = true;
        propertyIds.push(_propertyId);

        Property memory newProperty = Property({
            forSale: true,
            price: 3.5 ether,
            owner: msg.sender,
            name: _propertyName,
            description: _propertyDescription,
            location: _propertyLocation
        });

        properties[_propertyId] = newProperty;
       

    }


    function buyProperty(uint256 _propertyId) public view isValidID(_propertyId) returns(bool sold){
        
        
    }

}