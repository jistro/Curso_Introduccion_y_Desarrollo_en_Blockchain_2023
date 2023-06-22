// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";

error noOwner();
error noEmpleado();

contract AccesoPrueba is AccessControl {

    struct persona {
        string nombre;
        uint edad;
        string email;
        string telefono;
        bool estatus;
    }

    mapping(address => persona) public listaEmpleados;

    bytes32 public constant ADMIN_ROL = keccak256("ADMIN_ROL");
    bytes32 public constant EMPLEADO_ROL = keccak256("EMPLEADO_ROL");


    constructor() {
        _setupRole(ADMIN_ROL, msg.sender);
    }
    

    modifier soloAdmin() {
        if ( !( hasRole(ADMIN_ROL, msg.sender) ) ) {
            revert noOwner();
        }
                    _;
    }

    modifier soloEmpleado() {
        if ( !( hasRole(EMPLEADO_ROL, msg.sender) ) ) {
            revert noEmpleado();
        }
        _;
    }

    modifier soloEmpresa() {
        if ( !( hasRole(ADMIN_ROL, msg.sender) || hasRole(EMPLEADO_ROL, msg.sender) ) ) {
            revert noEmpleado();
        }
        _;
    }

    function agregarEmpleado(
        address _direccion,
        string memory _nombre,
        uint _edad,
        string memory _email,
        string memory _telefono
    ) public soloAdmin {
        listaEmpleados[_direccion] = persona(_nombre, _edad, _email, _telefono, true);
        _setupRole(EMPLEADO_ROL, _direccion);
    }

    function eliminarEmpleado(address _direccion) public soloAdmin {
        listaEmpleados[_direccion].estatus = false;
        revokeRole(EMPLEADO_ROL, _direccion);
    }

    function verDatosPersonales() public view soloEmpleado returns (string memory, uint, string memory, string memory) {
        return (
            listaEmpleados[msg.sender].nombre,
            listaEmpleados[msg.sender].edad,
            listaEmpleados[msg.sender].email,
            listaEmpleados[msg.sender].telefono
        );
    }

    function verDatosSimples(address _direccionEmpleado) public view soloEmpresa returns (string memory, string memory) {
        return (
            listaEmpleados[_direccionEmpleado].nombre,
            listaEmpleados[_direccionEmpleado].email
        );
    }

}