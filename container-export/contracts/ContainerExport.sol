pragma solidity >= 0.5.0 < 0.7.0;

contract ContainerExport {

  event NewCompany(string name, uint corporateId);

  struct Company {
    string name;
    uint corporateId;
  }
//Test syntax highlighting
  Company[] public companies;

  function createCompany(string _name, uint _corporateId) private {
    companies.push(_name, _corporateId);
  }
}
