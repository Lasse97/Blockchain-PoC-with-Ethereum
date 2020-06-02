pragma solidity >= 0.5.0 < 0.7.0;

import "./Owner.sol";
import "./erc721.sol"

contract ContainerExport is Owner, ERC721{
  event LogNewCompany(string _name, uint _corporateId);
   event LogNewContainer(string _containerName, uint _containerId);
   event LogCheckContainer(string _message);
   event LogTransfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
   event LogApproval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);


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
   mapping (address => Company) companies;
   mapping (address => Container) container;
   mapping (uint => address) idToAddress;
//mappings to track container
   mapping (uint256 => address) containerToOwner;
   mapping (address => uint256) ownerContainerCount;
   mapping (uint => address) transferApprovals;
   mapping (string => uint) containerNameToId;

   modifier onlyNewCompany() {
       require((address(msg.sender) != address(0))&&(companies[msg.sender].valid == false));
       _;
   }

//create new company
   function createCompany(string memory _name) public onlyNewCompany() {
   //  require((address(msg.sender) != address(0))&&(companies[msg.sender].valid == false));
     idToAddress[corporateId] = msg.sender;
     companies[msg.sender].name = _name;
     companies[msg.sender].corporateId = corporateId;
     companies[msg.sender].valid = true;
     emit LogNewCompany(_name, corporateId);
   }

//   modifier onlyNewContainer(string memory _containerName) {
//       require();
//       _;
//   }

//create new container
   function createContainer(string memory _containerName) public {
     //require((address(msg.sender) != address(0))&&(container[msg.sender].valid == false));
     containerToOwner[containerId] = msg.sender;
     container[msg.sender].containerName = _containerName;
     container[msg.sender].containerId = containerId;
     container[msg.sender].valid = true;
     ownerContainerCount[msg.sender]++;
     containerNameToId[_containerName] = containerId;
     emit LogNewContainer(_containerName, containerId);
     containerId++;
   }
//get the name of the current owner/position of the container
   function getContainerOwner(uint _containerId) public view returns (string memory) {
       return companies[containerToOwner[_containerId]].name;
   }

   function balanceOf(address _owner) external view returns (uint256) {
     return ownerContainerCount[_owner];
   }

//container is assigned to owner
   function ownerOf(uint256 _tokenId) external view returns (address) {
     return containerToOwner[_tokenId];
   }

//container is transferred from one company to another
   function _transfer(address _from, address _to, uint256 _tokenId) private {
     ownerContainerCount[_to]++;
     ownerContainerCount[_from]--;
     containerToOwner[_tokenId] = _to;
     emit LogTransfer(_from, _to, _tokenId);
   }

   function transferFrom(address _from, address _to, uint256 _tokenId) external payable {
//sender must be owner of the container or the sender has the transfer approval
     require (containerToOwner[_tokenId] == msg.sender || transferApprovals[_tokenId] == msg.sender);
     _transfer(_from, _to, _tokenId);
   }

//check if sender is owner of the container
   modifier onlyOwnerOf(uint _containerID) {
     require(msg.sender == containerToOwner[_containerID]);
     _;
   }

//sender approved the transfer
   function approve(address _approved, uint256 _tokenId) external payable onlyOwnerOf(_tokenId) {
     transferApprovals[_tokenId] = _approved;
     emit LogApproval(msg.sender, _approved, _tokenId);
   }

}
