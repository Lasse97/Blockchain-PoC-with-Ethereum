pragma solidity >= 0.5.0 < 0.7.0;

contract ContainerExport {
  constructor() public {
  }
  struct Company {
    string name;
    uint corporateId;
  }

  Company[] public companies;

  function newCompany(string _name, uint _corporateId){
    companies.push(_name, _corporateId);
  }
}
