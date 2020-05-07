pragma solidity >= 0.5.0 < 0.7.0;

import "./Owner.sol";

contract ContainerExport is Owner{

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
  mapping (address => string) containerID;

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
}
