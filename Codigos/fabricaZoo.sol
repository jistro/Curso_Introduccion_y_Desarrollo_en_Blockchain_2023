// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import {RegistroZoo} from "./zoo.sol";

contract FablicaDeContrato {
    address immutable public i_owner;
    constructor() {
        i_owner = msg.sender;
    }

    RegistroZoo [] public ListaContratos;

    function creaContrato() public {
        RegistroZoo nuevoContrato = new RegistroZoo(msg.sender, address(this));
        ListaContratos.push(nuevoContrato);
    }
    

    function llamadaContratoAgregar (
        uint _index, string memory _codigoAnimal,
        string memory _nombre, string memory _especie,
        uint8 _edad, address _cuidador
        ) public returns(bool){
        ListaContratos[_index].agregarAnimal(_codigoAnimal, _nombre, _especie, _edad, _cuidador);
        return true;
    }


    function llamadaContratoVer (uint _index, string memory _tagAnimal) public view returns(string memory, string memory, uint8, address){
        return ListaContratos[_index].obtenerDataAnimal(_tagAnimal);
    }

    function interacontrato(uint index) public view returns (address){
        return ListaContratos[index].llamada();
    }

    function ownersDelContrato(uint _index) public view returns(address, address){
        return (
            ListaContratos[_index].i_owner(),
            ListaContratos[_index].i_ownerSecundario()
        );
    }



}