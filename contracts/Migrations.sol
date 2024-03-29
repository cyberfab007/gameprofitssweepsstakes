pragma solidity >=0.4.22 <0.6.0;

import "./Owned.sol";

contract Migrations is Owned {

  uint public last_completed_migration;

  function setCompleted(uint completed) onlyOwner public {
    last_completed_migration = completed;
  }

  function upgrade(address new_address) onlyOwner public {
    Migrations upgraded = Migrations(new_address);
    upgraded.setCompleted(last_completed_migration);
  }
}
