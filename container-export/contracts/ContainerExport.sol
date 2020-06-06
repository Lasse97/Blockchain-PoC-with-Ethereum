pragma solidity >= 0.5.0 < 0.7.0;

import "./Owner.sol";
import "./erc721.sol"

contract ContainerExport is Owner, ERC721{

  //Set up events
event LogNewCompany(string name, uint corporateId);
event LogNewContainer(string containerName, uint containerId);
event LogCheckContainer(string message);
event LogTransfer(address indexed from, address indexed to, uint256 indexed tokenId);
event LogApproval(address indexed owner, address indexed approved, uint256 indexed tokenId);


struct Company {
  string name;
  uint corporateId;
  bool valid;
}

struct Container {
  string containerName;
  uint containerId;
  bool valid;
}
//global variable for corporate and containerId
uint public corporateId = 1;
uint public containerId = 1;

//mappings to assign addresses to the companies and containers
mapping (address => Company) public companies;
mapping (address => Container) public container;
mapping (uint => address) public idToAddress;
//mappings to track container
mapping (uint256 => address) public containerToOwner;
mapping (address => uint256) public ownerContainerCount;
mapping (uint => address) public transferApprovals;
mapping (string => uint) public containerNameToId;

mapping (bytes32 => Container) public containers;

function hash(address exchange, bytes32 password) public view returns(bytes32 hash){
    require(exchange != address(0x0), "The address can't be 0x0");
    hash = keccak256(abi.encodePacked(exchange, password, address(this)));

}

modifier onlyNewCompany() {
    require((address(msg.sender) != address(0))&&(companies[msg.sender].valid == false));
    _;
}

//create new company
function registerCompany(string memory name) public onlyNewCompany() {
//  require((address(msg.sender) != address(0))&&(companies[msg.sender].valid == false));
  idToAddress[corporateId] = msg.sender;
  companies[msg.sender].name = name;
  companies[msg.sender].corporateId = corporateId;
  companies[msg.sender].valid = true;
  emit LogNewCompany(name, corporateId);
}

///   modifier onlyNewContainer(string memory _containerName) {
//        require();
//      _;
//    }
//create new container
function createContainer(string memory containerName) public {
  //require((address(msg.sender) != address(0))&&(container[msg.sender].valid == false));
  containerToOwner[containerId] = msg.sender;
  container[msg.sender].containerName = containerName;
  container[msg.sender].containerId = containerId;
  container[msg.sender].valid = true;
  ownerContainerCount[msg.sender]++;
  containerNameToId[containerName] = containerId;
  emit LogNewContainer(containerName, containerId);
  containerId++;
}

function balanceOf(address owner) external view returns (uint256) {
  return ownerContainerCount[owner];
}

//container is assigned to owner
function ownerOf(uint256 tokenId) external view returns (address) {
  return containerToOwner[tokenId];
}

//container is transferred from one company to another
function _transfer(address from, address to, uint256 tokenId) private {
  ownerContainerCount[to]++;
  ownerContainerCount[from]--;
  containerToOwner[tokenId] = to;
  emit LogTransfer(from, to, tokenId);
}

function transferFrom(address from, address to, uint256 tokenId) external payable {
//sender must be owner of the container or the sender has the transfer approval
  require (containerToOwner[tokenId] == msg.sender || transferApprovals[tokenId] == msg.sender);
  _transfer(from, to, tokenId);
}

//check if sender is owner of the container
modifier onlyOwnerOf(uint containerID) {
  require(msg.sender == containerToOwner[containerID]);
  _;
}

//sender approved the transfer
function approve(address approved, uint256 tokenId) external payable onlyOwnerOf(tokenId) {
  transferApprovals[tokenId] = approved;
  emit LogApproval(msg.sender, approved, tokenId);
}

}
