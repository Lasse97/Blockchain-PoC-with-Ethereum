pragma solidity >= 0.5.0 < 0.7.0;

contract ContainerExport {

  event NewCompany(string name, uint corporateId);

  struct Company {
    string name;
    uint corporateId;
  }

  mapping (address => Company) public companies;
  mapping (address => uint) ownerCompanyCount;

  address[] public companyAddresses;

  function createCompany(string memory _name, uint _corporateId) public {
    require(ownerCompanyCount[msg.sender] == 0);
    companies[msg.sender].name = _name;
    companies[msg.sender].corporateId = _corporateId;
    ownerCompanyCount[msg.sender]++;
    emit NewCompany(_name, _corporateId);
    companyAddresses.push(msg.sender);
  }

  function getOwnerCompanyCount() public view returns (uint) {
    return (ownerCompanyCount[msg.sender]);
  }

  function getAllCompanies() external view returns (address[] memory) {
      return companyAddresses;
  }

}
