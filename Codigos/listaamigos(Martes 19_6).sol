// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

 /// @title lista de contacto de amigos
 /// @author Kevin Raul Padilla Islas
 /// @notice este contrato registra a amigos como una lista de contratos
 /// @dev este cotrato usa arreglos de struct para almacenar nuestras variables


contract listaAmigos {
   
    struct amigo {
        string nombre;
        string apellido;
        uint8 edad;
        address direccion;
    }

    amigo [] amigos;

    mapping (string => uint) public indiceAmigos;
    
    /// @notice registra a nuestro amigo
    /// @dev esta funcion almacena en el arreglo de struct a nuestro amigo
    /// @param _nombre nombre o nombres del amigo
    function agregarAmigo(string memory _nombre, string memory _apellido, uint8 _edad, address _direccion) public{
        amigo memory nuevoAmigo = amigo(_nombre,_apellido,_edad,_direccion);
        amigos.push(nuevoAmigo);
        indiceAmigos[_nombre] = amigos.length-1;
    }

    /// @return retorna al amigo
    function mostrarAmigo (string memory _nombre) public view returns(string memory, string memory, uint16, address){
        uint indice = indiceAmigos[_nombre];
        return (amigos[indice].nombre, amigos[indice].apellido,
                amigos[indice].edad, amigos[indice].direccion);
    }

}
