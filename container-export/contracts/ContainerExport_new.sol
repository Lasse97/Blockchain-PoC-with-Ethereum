pragma solidity >= 0.5.0 < 0.7.0;


contract ContainerExport is Owner {

  //Set up events
  event LogCompanyRegistered(address indexed company);
  event LogCompanyDeregistered(address indexed company);
  event LogNewContainer(bytes32 hash, string containerName, uint containerId);
  event LogTransfer(bytes32 hash, address indexed from, address indexed to, uint256 indexed containerId);

  //Struct with properties of the container
  struct Container {
  address payable owner;
  string containerName;
  uint containerId;
  }

  //Setting up mappings

  //Hash is assigned to a container
  mapping (bytes32 => Container) public container;
  //Saving the registered companies
  mapping (address => bool) public companies;
  //Counting the containers owned by a company
  mapping (address => uint256) public ownerContainerCount;

  //global variable containerId
  uint public containerId = 1;

  //hash a password inside the contract
  function generateHash(address company, bytes32 password) public view returns(bytes32 hash){
    require(company != address(0x0), "The address can't be 0x0");
    hash = keccak256(abi.encodePacked(company,password));
  }

  //Register a company that can transfer containers. Only the contract owner may call the function.
  //returns true if registration is successful
  function registerCompany(address company) public onlyOwner returns (bool) {
    require(company != address(0), "Company is the zero address");
    require(!companies[company], "Company already registered");
    companies[company] = true;
    emit LogCompanyRegistered(company);
    return true;
  }

  //Deregister a company so that no more containers can be transferred. Only the contract owner may call the function.
  //returns true if deregistration is successful
  function deregisterCompany(address company) public onlyOwner returns (bool) {
    require(companies[company], "Company not registered");
    companies[company] = false;
    emit LogCompanyDeregistered(company);
    return true;
  }

  //Create new container and store in storage c with related hash
  function createContainer(bytes32 hash, string memory containerName) public {
  require(container[hash].owner == address(0x0) , "Container already registered");
  Container storage c = container[hash];
  c.owner = msg.sender;
  c.containerName = containerName;
  c.containerId = containerId;
  ownerContainerCount[msg.sender]++;
  emit LogNewContainer(hash, containerName, containerId);
  }

  //Function to retrieve the number of containers of an owner
  function balanceOf(address owner) external view returns (uint256) {
  return ownerContainerCount[owner];
  }

  //container is assigned to owner
  function ownerOf(bytes32 hash) external view returns (address) {
  return container[hash].owner;
  }

  //Container is transferred from one company to another. Only the container owner can transfer the container.
  function transferContainer(bytes32 hash, address payable from, address payable to) public payable {
    require (container[hash].owner == msg.sender, "The sender must be the owner of the container");
    ownerContainerCount[to]++;
    ownerContainerCount[from]--;
    container[hash].owner = to;
    emit LogTransfer(hash, from, to, containerId);
  }

}
