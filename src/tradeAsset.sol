// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../lib/openzeppelin-contracts/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC1155/IERC1155.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "./Property.sol";
import "./IToken.sol";

import "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract tradeAsset is ERC1155Holder {
    //function events
    event PropertyListed(
        uint256 indexed propertyId,
        uint256 indexed nftId,
        address indexed oldOwner
    );
    event PropertySold(uint256 indexed propertyId, address indexed newOwner);
    event onlyOwnerWithdrawal(address indexed moderator, uint256 indexed propertyNftId, address indexed recipientAddress, IERC1155  tokenAddress);

    //chainlink price feed addresses.
    AggregatorV3Interface ETHLINK =
        AggregatorV3Interface(0xDC530D9457755926550b59e8ECcdaE7624181557);
    AggregatorV3Interface ETHAAVE =
        AggregatorV3Interface(0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012);
    AggregatorV3Interface ETHDAI =
        AggregatorV3Interface(0x773616E4d11A78F511299002da57A0a94577F1f4);
    AggregatorV3Interface ETHUSDT =
        AggregatorV3Interface(0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46);
    AggregatorV3Interface ETHUNI =
        AggregatorV3Interface(0xD6aA3D25116d8dA79Ea0246c4826EB951872e02e);

    //Accepted tokens addresses
    IERC20 internal LINK;
    IERC20 internal AAVE;
    IERC20 internal DAI;
    IERC20 internal USDT;
    IERC20 internal UNI;

    //uint256 public tokenDecimal;
    address public moderator;

    //Property info struct
    struct Property {
        bool forSale;
        address owner;
        string name;
        IERC1155 nft;
        uint256 nftId;
        string description;
        string location;
        uint256 price;
    }

    //mapping of property ID to struct that contains property info
    mapping(uint256 => Property) public properties;
    mapping(uint256 => bool) idUsed;

    //Array of listed property IDs
    uint256[] public propertyIds;

    constructor() {
        //tokenDecimal = 1e8;
        LINK = IERC20(0x514910771AF9Ca656af840dff83E8264EcF986CA);
        AAVE = IERC20(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
        DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        USDT = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        UNI = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);

        moderator = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == moderator, "Not a moderator");
        _;
    }

    modifier isValidID(uint _propertyId) {
        require((idUsed[_propertyId]), "INVALID ID");
        _;
    }

    function getPrice(
        AggregatorV3Interface _token2swap
    ) public view returns (int) {
        (, int256 price, , , ) = _token2swap.latestRoundData();

        return (price);
    }

    //int ethPrice = getPrice(ETHUSD, tokenDecimal);

    function listProperty(
        uint256 _propertyId,
        string memory _propertyName,
        string memory _propertyDescription,
        string memory _propertyLocation,
        IERC1155 _propertyNft,
        uint256 _propertyNftId
    ) public {
        //require(msg.value > 0, "Insufficient Fund");
        require(idUsed[_propertyId] == false, "ID already taken");
        idUsed[_propertyId] = true;
        propertyIds.push(_propertyId);
        _propertyNft.safeTransferFrom(
            msg.sender,
            address(this),
            _propertyNftId,
            1,
            "0x0"
        );

        Property memory newProperty = Property({
            forSale: true,
            price: 3.5 ether,
            owner: msg.sender,
            name: _propertyName,
            description: _propertyDescription,
            location: _propertyLocation,
            nft: _propertyNft,
            nftId: _propertyNftId
        });

        properties[_propertyId] = newProperty;

        emit PropertyListed(_propertyId, _propertyNftId, msg.sender);
    }

    function buyPropertyUSDT(uint256 _propertyId) public {
        buyProperty(_propertyId, ETHUSDT, USDT);
    }

    function buyPropertyDAI(uint256 _propertyId) public {
        buyProperty(_propertyId, ETHDAI, DAI);
    }

    function buyPropertyUNI(uint256 _propertyId) public {
        buyProperty(_propertyId, ETHUNI, UNI);
    }

    function buyPropertyLINK(uint256 _propertyId) public {
        buyProperty(_propertyId, ETHLINK, LINK);
    }

    function buyPropertyAAVE(uint256 _propertyId) public {
        buyProperty(_propertyId, ETHAAVE, AAVE);
    }

    function buyProperty(
        uint256 _propertyId,
        AggregatorV3Interface _token2swap,
        IERC20 _tokenAddress
    ) internal isValidID(_propertyId) {
        Property storage property = properties[_propertyId];
        require(property.forSale == true, "Property sold out");
        uint256 usdt = uint256(getPrice(_token2swap));
        uint256 propertyPrice = property.price * usdt;
        address newOwner = msg.sender;
        require(
            propertyPrice <= _tokenAddress.balanceOf(newOwner),
            "Insufficient balance for property purchase"
        );
        _tokenAddress.transferFrom(newOwner, address(this), propertyPrice);

        _tokenAddress.transfer(property.owner, propertyPrice);

        (property.nft).safeTransferFrom(
            address(this),
            newOwner,
            property.nftId,
            1,
            "0x0"
        );
        
        property.forSale = false;
        property.owner = newOwner;

        emit PropertySold(_propertyId, newOwner);
    }

    function withdrawNFT(IERC1155 _tokenAddress, address _recipientAddress, uint256 _propertyNftId, uint256 _propertyID) external onlyOwner() {
        require(_recipientAddress != address(0), "Invalid address");
        require(idUsed[_propertyID], "Invalid PropertyID");
        Property storage property = properties[_propertyID];
        require(property.nftId == _propertyNftId, "Invalid _propertyNftId");
        _tokenAddress.safeTransferFrom(
            address(this),
            _recipientAddress,
            _propertyNftId,
            1,
            "0x0"
        );

        emit onlyOwnerWithdrawal(msg.sender, _propertyNftId, _recipientAddress, _tokenAddress);
    }

    function withdrawTokens(IERC20 _tokenAddress, address _recipientAddress, uint _amount) external onlyOwner(){
        require(_recipientAddress != address(0), "Invalid address");
        require(_amount <= _tokenAddress.balanceOf(address(this)), "Insufficient acount balance");
        _tokenAddress.transferFrom(address(this), _recipientAddress, _amount);
    }



    fallback() external payable {}

    receive() external payable {}
}
