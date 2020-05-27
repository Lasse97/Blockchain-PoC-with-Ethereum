pragma solidity >= 0.5.0 < 0.7.0;

import "./ContainerExport.sol";

contract StatusRequest is ContainerExport {

  struct StatusInformation {
  bool containerKnown;
  bool releaseNumberKnown;
  bool clearedCustoms;
  bool containerDischarged;
  }


}
