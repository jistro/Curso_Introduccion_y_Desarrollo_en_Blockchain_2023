// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;



//1274233  859.4669
//1266567  854.2969 MXN
//1243857  838.9791 MXN
error noOwner();
error logica();
error tiempo();


// now, block.timestamp 
//segundos uint, int



contract RegistroZoo {
    //immutable
    //address public owner;
    address immutable public i_owner;
    address immutable public i_ownerSecundario;
    constructor(address _owner, address _ownerSecundario) {
        //owner = msg.sender;
        i_owner = _owner;
        i_ownerSecundario = _ownerSecundario;
    }

    event nuevoAnimalEvento(string animalTag, string nombreAnimal, address cuidador);

    event edicion(address);

    modifier soloOwner {
        //require(msg.sender == i_owner || msg.sender == i_ownerSecundario, "no eres dueno del contrato");
        if (msg.sender != i_owner && msg.sender != i_ownerSecundario){
            revert noOwner();
        }
        _;
    }

    function llamada() public view returns(address){
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

    mapping (string => uint) indexLista;

    function agregarAnimal( string memory _codigo, string memory _nombre, 
                            string memory _especie,uint8 _edad,
                            address _cuidador) public soloOwner returns(bool){

        animal memory nuevoAnimal = animal(_cuidador, _nombre, _especie, _edad, block.timestamp);
        ListaAnimales.push(nuevoAnimal);
        indexLista[_codigo] = ListaAnimales.length - 1;
        emit nuevoAnimalEvento(_codigo, _nombre, _cuidador);
        return true;
    }

    function obtenerDataAnimal(string memory _codigoAnimal) public view returns(string memory, 
                                                                                string memory, 
                                                                                uint8, 
                                                                                address){
        uint index = indexLista[_codigoAnimal];
        return (
            ListaAnimales[index].nombre,
            ListaAnimales[index].especie,
            ListaAnimales[index].edad,
            ListaAnimales[index].cuidador
        );
    }

    function editarCuidador(string memory _codigoAnimal, address _nuevoCuidador) public soloOwner {
        
        uint index = indexLista[_codigoAnimal];
        if (ListaAnimales[index].tiempoRegistro + 5 seconds >= block.timestamp){
            ListaAnimales[index].cuidador = _nuevoCuidador;
            emit edicion(msg.sender);
            obtenerDataAnimal(_codigoAnimal);
        }
        {
            revert tiempo();
        }
        
    }

    function editarAnno(string memory _codigoAnimal, uint8 _nuevaEdad) public soloOwner {
        
        uint index = indexLista[_codigoAnimal];
        if (_nuevaEdad > ListaAnimales[index].edad){

            ListaAnimales[index].edad = _nuevaEdad;
            emit edicion(msg.sender);
            obtenerDataAnimal(_codigoAnimal);
        }
        else
        {
            revert logica();
        }
    }
}

contract a {}
contract b {}