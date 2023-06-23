// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
error noOwner();
error noTransferencia();
contract fondeo is AccessControl{
    bytes32 public constant ADMIN_ROL = keccak256("ADMIN_ROL");
    constructor() {
        _setupRole(ADMIN_ROL, msg.sender);
    }
    

    modifier soloAdmin() {
        if ( !( hasRole(ADMIN_ROL, msg.sender) ) ) {
            revert noOwner();
        }
                    _;
    }

    function nuevoAdmin(address _admin) public soloAdmin  returns (bool) {
        _setupRole(ADMIN_ROL,_admin);
        return true;
    }

    address[] donanteslista;
    mapping (address => uint) donanteDinero;

    function deposito() public payable{
        donanteslista.push(msg.sender);
        //donanteDinero[msg.sender] = donanteDinero[msg.sender] + msg.value;
        donanteDinero[msg.sender] += msg.value;

        // += -= *= /= 
    }

    function verDineroDonado() public view returns (uint) {
        return donanteDinero[msg.sender];
    }

    function retiroEfectivo() public soloAdmin{
        if ((msg.sender).send(address(this).balance)){
            for (uint256 donanteIndex = 0; donantendex < donanteslista.length; donanteIndex++){
            address donanteDireccion = donantesLista[donanteIndex];
            donanteDinero[donanteDireccion]=0;
            }
            donanteslista[] = new address[](0);
        }
        else {
            revert noTransferencia();
        }
        

        /*
            1) send
            bool exito = (msg.sender).send(address(this).balance)
            2300 gas 
            2) transfer -- nuca usen este, jamas, NUNCA
            JAMAS
            (msg.sender).transfer(address(this).balance)
            3) call 
            (bool exito, bytes data)=(msg.sender).call{value: address(this).balance}("");

        */
    }
}