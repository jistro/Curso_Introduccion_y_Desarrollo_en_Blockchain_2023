// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.7;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library convertidorDePrecio {
    // contract AVAX/USD 0x5498BB86BC934c8D34FDA08E81D444153d0D06aD
    // ABI (lista de funciones) es @chainlink/contracts/src/v0.8/
    function getPrecio() internal view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x5498BB86BC934c8D34FDA08E81D444153d0D06aD);
        (
            /* uint80 roundID */,
            int256 price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        /// Ejemplo el precio de un AVAX en terminos de USD
        /// es 10000000000 pero para buscar el decimal 
        // usamos decimals() que nos muestra cuanto decimales tiene
        // es decir como dividirlo para obtener el precio real
        return uint256(price * 1e10);
    }

    function getTazaDeConversion(uint256 _cantidadAVAX) internal view returns (uint256){
        uint256 precio = getPrecio();
        // tanto precio como _cantidadAVAX tienen 18 decimales
        // si multiplicamos ambos nos dara 36 decimales
        // pero como no podemos tener mas de 18 decimales
        // dividimos entre 1e18 para obtener el precio real
        // recordar 1e18=1000000000000000000
        // se multiplica primero para evitar errores de redondeo
        uint256 tazaDeConversion = (precio * _cantidadAVAX) / 1e18;
        return tazaDeConversion;
        /*
        tomemos de ejemplo queremos saber cuanto vale 1 AVAX en USD
        teoricamente diremos que vale 2000 USD
        es decir 
        1 AVAX      1_000000000000000000
        2000 USD 2000_000000000000000000
        entonces (1_000000000000000000 * 2000_000000000000000000) / 1_0000000000000000000 = 2000 
        */
    }


    function getVersion() internal view returns (uint256){
        return AggregatorV3Interface(0x5498BB86BC934c8D34FDA08E81D444153d0D06aD).version();
    }
}