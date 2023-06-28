// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// me quede en el minuto 5:34:53 de la leccion 4 'advanced solidity inmutable and constant'
// https://youtu.be/umepbfKp5rI?t=20093

//import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

import {convertidorDePrecio} from "./PriceConverter.sol";

// podemos ser gas friendly usando Error esto nos permite en vez de usar require
// que almacena un string y con ello gastamos mas gas podemos usar Error que es un
// codigo de error que es mas barato de almacenar y con ello gastamos menos gas
// podemos usarlo en 0.8.4 o superior

error NoOwner();

contract FundMe {
    // indica que la libreria convertidorDePrecio esta en el archivo PriceConverter.sol
    // solo podemos usarlo para uint256
    // si queremos para cualquier tipo de variable usamos using convertidorDePrecio for *
    using convertidorDePrecio for uint256;
    /// @notice the contract if for avalanche testnet
    
    // para bajar los fees de gas usaremos const y immutable

    //address public owner;

    address public immutable i_owner;
    constructor() {
        
        //owner = msg.sender;
        i_owner = msg.sender;
    }

    modifier soloOwner() {
        //require(msg.sender == owner, "solo el owner puede retirar");
        //require(msg.sender == i_owner, "solo el owner puede retirar");
        if (msg.sender != i_owner) {
            // revert es una funcion que se usa para revertir la transaccion
            revert NoOwner();
        }
        _;
    }
        

    /*
    /// @notice A function that allows anyone to fund the contract
    /// @dev All the funds will be stored in the contract
    function fund() public payable {
        // msg.sender es la funcion que nos muestra cuanto dinero se envio
        // 1e18 es 1 ether que es igual a 1000000000000000000 wei que es 1(10^18)
        //ver eth-converter.com para mas informacion
        // un revert significa que la transaccion no se realizo y se devuelve el dinero 
        // a la cuenta que lo envio y el gas que quedo 
        // pero si es antes de el revert hay algunas cosas que se pueden hacer
        // no se haran cambios pero si gastara gas
        require(msg.value >= 1e18, "nesecitas enviar mas de 1 ether");
    }*/
    uint256 public constant MINIMO_USD = 5e18;  //menor costo de gas
    //uint256 public minimoUSD = 5e18;          //mayor costo de gas

        

    address[] public donantes;
    mapping(address donante => uint256 cantidadDonada) public donanteInfo;

    function fund() public payable {
        require (msg.value.getTazaDeConversion() >= MINIMO_USD, "nesecitas gastar mas AVAX");
        //require(getTazaDeConversion(msg.value) >= minimoUSD, "nesecitas gastar mas AVAX");
        //donanteInfo[msg.sender] = donanteInfo[msg.sender] + msg.value;
        donanteInfo[msg.sender] += msg.value;
        donantes.push(msg.sender);
        
    }

    // por si la persona no usa la funcion de fund
    // podemos usar la funcion de fallback y recive 
    // fallback solo se usa para recibir dinero
    // receive usa para recibir dinero y ejecutar una funcion

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }


    function withdraw() public soloOwner {
        (bool exito,) = msg.sender.call{value: address(this).balance}("");
        require(exito, "la transferencia fallo");

        for (uint256 donanteIndex = 0; donanteIndex < donantes.length; donanteIndex++){
            address donantedireccion = donantes[donanteIndex];
            donanteInfo[donantedireccion] = 0;
        }
        // resetear el arreglo de donantes
        donantes = new address[](0);

        
        /*
        3 maneras de transferir dinero
        transfer ------------------------------------------
        (msg.sender).transfer(address(this).balance);
        donde 
        address(this).balance es la cantidad de dinero que tiene el contrato
        transfer es la cantidad de dinero que se le va a enviar
        msg.sender es la direccion de la persona que envio el dinero al contrato

        la transferencia esta puesta a 2300 gas y si se usa mas gas 
        lanza un error 
        send ----------------------------------------------
        (msg.sender).send(address(this).balance);
        donde
        address(this).balance es la cantidad de dinero que tiene el contrato
        send es la cantidad de dinero que se le va a enviar
        msg.sender es la direccion de la persona que envio el dinero al contrato

        la transferencia esta puesta a 2300 gas y si se usa mas gas
        no lanza un error pero devuelve un booleano
        pero si se usa solo no hara revert del contrato y se perdera el gas en demas
        y si hay mas que ejecutar gastara el gas que le sigue de ejecutar
        para ello usamos 

        bool exito = msg.sender.send(address(this).balance);
        require(exito, "la transferencia fallo");
        call ---------------------------------------------
        (msg.sender).call{value: address(this).balance}("");
        donde
        address(this) es la direccion del contrato
        address(this).balance es la cantidad de dinero que tiene el contrato
        value: address(this).balance es la cantidad de dinero que se le va a enviar
        ("") es la data que se le va a enviar
        {value: address(this).balance}("") es la data que se le va a enviar
        call es una funcion de bajo nivel para mandar data
        msg.sender es la direccion de la persona que envio el dinero al contrato

        esta funcion retorna 2 valores el primero es un booleano que indica 
        si la transaccion fue exitosa y el segundo es la data que se envio

        (bool exito, bytes memory dataReturned) = msg.sender.call{value: address(this).balance}("");

        podemos omitir el segundo valor si no lo necesitamos asi

        (bool exito,) = msg.sender.call{value: address(this).balance}("");
        
        esta transferencia pone completo el gas o se elige el gas que se va a usar

         ///////////////////////////////
        |   es recomendado usar call    |
        |   para transferir dinero     |
        |   a otras personas           |
        |   o contratos                |
         ///////////////////////////////
        */
    }
    
    // podemos pasar lo de la libreria a aqui solo cambiamos de internal a public
    
}