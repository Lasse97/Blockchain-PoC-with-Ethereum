pragma solidity >= 0.5.0 < 0.7.0;


contract ContainerExport {

    //Set up events
    event LogCompanyRegistered(address indexed company);
    event LogCompanyDeregistered(address indexed company);
    event LogNewContainer(bytes32 hash, string containerName, uint containerId);
    event LogCheckContainer(string message);
    event LogTransfer(bytes32 hash, address indexed from, address indexed to, uint256 indexed containerId);


    struct Container {
      address payable owner;
      string containerName;
      uint containerId;
    }

    mapping (bytes32 => Container) public container;
//mappings to assign addresses to the companies and container
    mapping (address => bool) public companies;
//mappings to track container
    mapping (address => uint256) public ownerContainerCount;
    //global variable for corporate and containerId
    uint public containerId = 1;

    function generateHash(address company, bytes32 password) public view returns(bytes32 hash){
        require(company != address(0x0), "The address can't be 0x0");
        hash = keccak256(abi.encodePacked(company,password));
    }

    address private owner;

    event LogChangeOwner(address indexed sender, address indexed newOwner);

    constructor() public {
      owner = msg.sender;
    }

     modifier onlyOwner {
        require(msg.sender == owner,"The sender must be the owner");
        _;
    }


    function changeOwner(address newOwner) public onlyOwner returns(bool success){
        require(newOwner != address(0x0), "The address of the new owner should not be empty");
        owner = newOwner;
        emit LogChangeOwner(msg.sender, newOwner);
        return true;
    }

    function registerCompany(address company) public onlyOwner returns (bool) {
        require(company != address(0), "Company is the zero address");
        require(!companies[company], "Company already registered");
        companies[company] = true;
        emit LogCompanyRegistered(company);
        return true;
    }

    function deregisterCompany(address company) public onlyOwner returns (bool) {
        require(companies[company], "Company not registered");
        companies[company] = false;
        emit LogCompanyDeregistered(company);
        return true;
    }

//create new container
    function createContainer(bytes32 hash, string memory containerName) public {
      require(container[hash].owner == address(0x0) , "Container already registered");
      Container storage c = container[hash];
      c.owner = msg.sender;
      c.containerName = containerName;
      c.containerId = containerId;
      ownerContainerCount[msg.sender]++;
      emit LogNewContainer(hash, containerName, containerId);
    }

    function balanceOf(address owner) external view returns (uint256) {
      return ownerContainerCount[owner];
    }

//container is assigned to owner
    function ownerOf(bytes32 hash) external view returns (address) {
      return container[hash].owner;
    }

//container is transferred from one company to another

    function transferContainer(bytes32 hash, address payable from, address payable to) public payable {
        require (container[hash].owner == msg.sender, "The sender must be the owner of the container");
        ownerContainerCount[to]++;
        ownerContainerCount[from]--;
        container[hash].owner = to;
        emit LogTransfer(hash, from, to, containerId);
  }

}
