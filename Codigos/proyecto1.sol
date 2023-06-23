// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";

//1274233  859.4669
//1266567  854.2969 MXN
//1243857  838.9791 MXN
error noOwner();
error logica();
error tiempo();

// now, block.timestamp
//segundos uint, int

contract FablicaDeContrato is AccessControl {
    //address public immutable i_owner;

    constructor() {
        //i_owner = msg.sender;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    function CrearAdmin(address _nuevoadmin) public returns(bool){
        _setupRole(ADMIN_ROLE, _nuevoadmin);
        return true;
    }

    function RevocarAdmin(address _admin) public returns (bool) {
        _revokeRole(ADMIN_ROLE,_admin);
        return true;
    }

    modifier soloAdmin(){
        //hasRole(variable_role, address)
        require(hasRole(ADMIN_ROLE, msg.sender), "no eres admin");
        _;
    }


    RegistroZoo[] public ListaContratos;

    function creaContrato() public soloAdmin {
        RegistroZoo nuevoContrato = new RegistroZoo(msg.sender, address(this));
        ListaContratos.push(nuevoContrato);
    }

    function llamadaContratoAgregar(
        uint _index,
        string memory _codigoAnimal,
        string memory _nombre,
        string memory _especie,
        uint8 _edad,
        address _cuidador
    ) public returns (bool) {
        ListaContratos[_index].agregarAnimal(
            _codigoAnimal,
            _nombre,
            _especie,
            _edad,
            _cuidador
        );
        return true;
    }

    function llamadaContratoVer(
        uint _index,
        string memory _tagAnimal
    ) public view returns (string memory, string memory, uint8, address) {
        return ListaContratos[_index].obtenerDataAnimal(_tagAnimal);
    }

    function interacontrato(uint index) public view returns (address) {
        return ListaContratos[index].llamada();
    }

    function ownersDelContrato(
        uint _index
    ) public view returns (address, address) {
        return (
            ListaContratos[_index].i_owner(),
            ListaContratos[_index].i_ownerSecundario()
        );
    }
}

contract RegistroZoo {
    //immutable
    //address public owner;
    address public immutable i_owner;
    address public immutable i_ownerSecundario;

    constructor(address _owner, address _ownerSecundario) {
        //owner = msg.sender;
        i_owner = _owner;
        i_ownerSecundario = _ownerSecundario;
    }

    event nuevoAnimalEvento(
        string animalTag,
        string nombreAnimal,
        address cuidador
    );

    event edicion(address);

    modifier soloOwner() {
        //require(msg.sender == i_owner || msg.sender == i_ownerSecundario, "no eres dueno del contrato");
        if (msg.sender != i_owner && msg.sender != i_ownerSecundario) {
            revert noOwner();
        }
        _;
    }

    function llamada() public view returns (address) {
        return msg.sender;
    }

    struct animal {
        address cuidador;
        string nombre;
        string especie;
        uint8 edad;
        uint tiempoRegistro;
    }

    animal[] public ListaAnimales;

    mapping(string => uint) indexLista;

    function agregarAnimal(
        string memory _codigo,
        string memory _nombre,
        string memory _especie,
        uint8 _edad,
        address _cuidador
    ) public soloOwner returns (bool) {
        animal memory nuevoAnimal = animal(
            _cuidador,
            _nombre,
            _especie,
            _edad,
            block.timestamp
        );
        ListaAnimales.push(nuevoAnimal);
        indexLista[_codigo] = ListaAnimales.length - 1;
        emit nuevoAnimalEvento(_codigo, _nombre, _cuidador);
        return true;
    }

    function obtenerDataAnimal(
        string memory _codigoAnimal
    ) public view returns (string memory, string memory, uint8, address) {
        uint index = indexLista[_codigoAnimal];
        return (
            ListaAnimales[index].nombre,
            ListaAnimales[index].especie,
            ListaAnimales[index].edad,
            ListaAnimales[index].cuidador
        );
    }

    function editarCuidador(
        string memory _codigoAnimal,
        address _nuevoCuidador
    ) public soloOwner {
        uint index = indexLista[_codigoAnimal];
        if (
            ListaAnimales[index].tiempoRegistro + 5 seconds >= block.timestamp
        ) {
            ListaAnimales[index].cuidador = _nuevoCuidador;
            emit edicion(msg.sender);
            obtenerDataAnimal(_codigoAnimal);
        }
        {
            revert tiempo();
        }
    }

    function editarAnno(
        string memory _codigoAnimal,
        uint8 _nuevaEdad
    ) public soloOwner {
        uint index = indexLista[_codigoAnimal];
        if (_nuevaEdad > ListaAnimales[index].edad) {
            ListaAnimales[index].edad = _nuevaEdad;
            emit edicion(msg.sender);
            obtenerDataAnimal(_codigoAnimal);
        } else {
            revert logica();
        }
    }
}
