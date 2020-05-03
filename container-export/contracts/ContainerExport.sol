pragma solidity >= 0.5.0 < 0.7.0;

import "./Owner.sol";

contract ContainerExport is Owner {

  event NewCompany(string name, uint corporateId, Actors _actors);

  enum Actors { trucker, forwarder, terminal }

  struct Company {
    string name;
    uint corporateId;
    Actors actors;
  }

  mapping (address => Company) public companies;

  address[] public companyAddresses;

  function createCompany(string memory _name, uint _corporateId, Actors _actors) public {
# ist die Überprüfung noch notwendig, wenn ich den Owner habe? eher ja, weil so verhinntert
# wird, dass mehr als eine Company angemeldet werden kann
    for (uint i=0; i < companyAddresses.length; i++) {
        require(msg.sender != companyAddresses[i]);
    }
    companies[msg.sender].name = _name;
    companies[msg.sender].corporateId = _corporateId;
    companies[msg.sender].actors = _actors;
    emit NewCompany(_name, _corporateId, _actors);
    companyAddresses.push(msg.sender);
  }

  function getAllCompanies() external view returns (address[] memory) {
    return companyAddresses;
  }

  function getCompanyActor() external view returns (Actors) {
    return companies[msg.sender].actors;
  }

}
