pragma solidity >= 0.5.0 < 0.7.0;

import "./Owner.sol";
import "./erc721.sol"

contract ContainerExport is Owner, ERC721{

  event NewCompany(string _name, uint _corporateId);
  event CheckContainer(string _message);

  struct Company {
    string name;
    uint corporateId;
    bool valid;
  }

  uint public corporateId = 1;

  mapping (address => Company) public companies;
  mapping (uint => address) public idToAddress;
  mapping (address => uint) containerToOwner;
  mapping (address => uint) ownerContainerCount;
  mapping (uint => address) transferApprovals;

  function createCompany(string memory _name) public {
    require((address(msg.sender) != address(0))&&(companies[msg.sender].valid == false));
    idToAddress[corporateId] = msg.sender;
    companies[msg.sender].name = _name;
    companies[msg.sender].corporateId = corporateId;
    companies[msg.sender].valid = true;
    emit NewCompany(_name, corporateId);
    corporateId++;
  }

  function sendContainerID(address _recipient, string memory _containerID) public {
    containerID[_recipient] = _containerID;
  }

  function readContainerID() external view returns (string memory) {
    return containerID[msg.sender];
  }

  function balanceOf(address _owner) external view returns (uint256) {
    return ownerContainerCount[_owner];
  }

  function ownerOf(uint256 _tokenId) external view returns (address) {
    return containerToOwner[_tokenId];
  }

  function _transfer(address _from, address _to, uint256 _tokenId) private {
    ownerContainerCount[_to]++;
    ownerContainerCount[_from]--;
    containerToOwner[_tokenId] = _to;
    emit Transfer(_from, _to, _tokenId);
  }

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
    require (containerToOwner[_tokenId] == msg.sender || transferApprovals[_tokenId] == msg.sender);
    _transfer(_from, _to, _tokenId);
  }

  modifier onlyOwnerOf(uint _containerID) {
    require(msg.sender == containerToOwner[_containerID]);
    _;
  }

  function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
    transferApprovals[_tokenId] = _approved;
    emit Approval(msg.sender, _approved, _tokenId);
  }
}
