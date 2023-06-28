// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;


/// @title sistema principal de registro y control de personal de hospital
/// @author jistro.eth
/// @notice este contrato permite el registro del personal de un hospital
/// @dev este contrato es la fabrica de contratos 'Area'
/// @custom:experimental este contrato es experimental solo para fines educativos

/// @dev importamos la libreria de openzeppelin para el manejo de roles
///      e importamos el contrato 'Area' de la misma carpeta
import "@openzeppelin/contracts/access/AccessControl.sol";
import {Area} from "./Area.sol";


/// @dev definimos los errores personalizados
error SoloAdmin();
error SoloRecursosHumanos();
error FueraDeTiempoContrato();
error EmpleadoNoRegistrado();
error EmpleadoRegistrado();
error EmpleadoNoActivo();
error EmpleadoActivo();
error EmpleadoNoRecontratable();
error NoCero();
error AreaNoRegistrada();
error accesoDenegado();


contract Principal is AccessControl{
    /// @dev definimos los roles
    bytes32 public constant ADMIN_ROL = keccak256("ADMIN_ROL");
    bytes32 public constant EMPLEADO_RH_ROL = keccak256("EMPLEADO_RH_ROL");

    /// @notice direccion de los administradores
    /// @dev las direcciones de los administradores no son permanentes
    ///      por lo que se deben actualizar cada vez que se cambie de
    ///      administrador o el administrador principal cambie de direccion
    address public direccionAdmin1;
    address public direccionAdmin2;

    /// @notice constructor del contrato
    /// @dev el constructor asigna los roles a los administradores
    ///      y asigna las direcciones de los administradores
    /// @param _admin2 direccion del segundo administrador
    constructor(address _admin2){
        _setupRole(ADMIN_ROL, msg.sender);
        _setupRole(ADMIN_ROL, _admin2);
        direccionAdmin1 = msg.sender;
        direccionAdmin2 = _admin2;
    }

    /// @notice modificador que permite el acceso solo a los administradores
    /// @dev el modificador verifica que la direccion del usuario sea
    ///      la de alguno de los administradores
    modifier soloAdmin() {
        if ( !( hasRole(ADMIN_ROL, msg.sender) ) ) {
            revert SoloAdmin();
        }
                    _;
    }

    /// @notice modificador que permite el acceso solo a los empleados 
    ///         de recursos humanos
    /// @dev este modificador verifica que la direccion del usuario
    ///      sea la de algun empleado de recursos humanos
    ///      LOS EMPLEADOS DE RECURSOS HUMANOS SON LOS QUE REGISTRAN
    ///      AL PERSONAL DE LAS AREAS PUEDEN MODIFICAR DATOS Y PUEDEN
    ///      DAR DE BAJA/ALTA A LOS EMPLEADOS
    modifier soloEmpleadoRH() {
        if ( !( hasRole(EMPLEADO_RH_ROL, msg.sender) ) ) {
            revert SoloAdmin();
        }
        _;
    }

    /// @notice modificador que permite el acceso tanto a los administradores
    ///         como a los empleados de recursos humanos
    /// @dev este modificador verifica que la direccion del usuario
    ///      sea la de algun empleado de recursos humanos o algun
    ///      administrador
    modifier soloAdmin_o_EmpleadoRH() {
        if ( !( hasRole(ADMIN_ROL, msg.sender) ) && !( hasRole(EMPLEADO_RH_ROL, msg.sender) ) ) {
            revert SoloAdmin();
        }
        _;
    }

    

    /// @notice struct que define los datos de una persona
    /// @dev los datos de una persona son:
    ///      nombre, apellido, fecha de nacimiento, email, telefono,
    ///      rfc, estatus y fecha de baja
    ///      RECUERDA QUE ES EXCLUSIVO PARA EL PERSONAL DE RECURSOS HUMANOS
    struct persona {
        string nombre;
        string apellido;
        uint dia_nacimiento;
        uint mes_nacimiento;
        uint anio_nacimiento;
        string email;
        string telefono;
        bool estatus;
        uint fechaBaja;
    }

    /// @notice arreglo de personas en recursos humanos
    /// @dev este arreglo contiene los datos de las personas en 
    ///      recursos humanos
    persona[] public listaPersonasRH;

    /// @notice mappings que: 
    ///         1)  apunta a la direccion de una persona
    ///             y devuelve el indice en el arreglo antes mencionado
    ///             0x.... => index de listaDePersonasRH
    ///         2)  apunta al rfc de una persona
    ///             y devuelve la direccion de la persona
    ///             rfc => 0x....
    /// @dev este mapping es para poder acceder a los datos de una
    ///      persona en el arreglo
    mapping(string => uint) public IndexPersonaRH;
    mapping(string => address) public RFC_a_address_RH;
    
    /// @notice lista de direcciones las areas
    /// @dev este arreglo contiene las direcciones de los contratos
    ///      de las areas que fabrica este contrato
    address[] public listaContratosAreas;

    /// @notice mappings que apuntan a la direccion de un contrato de area
    ///         y devuelven:
    ///         0x.... => index en el caso de 'IndexContratoArea'
    ///         codigo de area => index en el caso de 'IndexContratoArea_conNombre'
    /// @dev estos mappings son para poder acceder a los datos de un contrato
    ///      de area en el arreglo
    mapping(address => uint) public IndexContratoArea;
    mapping(string => uint) public IndexContratoArea_conNombre;
    /// @notice mapping  que permite el acceso a empleado de RH
    mapping(string => bool) public PermisoRegistroRH_x_RFC;
    
    function RH_permiteRegistroEmpleado(string memory _rfc) public soloAdmin_o_EmpleadoRH{
        PermisoRegistroRH_x_RFC[_rfc] = true;
    }
    ////////////////////////////////////////////////////////////////////////////////
    /// @notice area de recursos humanos
    /// @dev esta area es la encargada de registrar a los empleados
    ////////////////////////////////////////////////////////////////////////////////

    /// @notice funcion que permite agregar un contrato de area de
    ///         recursos humanos
    /// @dev esta funcion solo puede ser ejecutada por un administrador
    ///      y agrega un empleado de recursos humanos al arreglo
    /// @param _rfc rfc del empleado de recursos humanos
    /// @param _nombre nombre del empleado de recursos humanos
    /// @param _apellido apellido del empleado de recursos humanos
    /// @param _dia_nacimiento dia de nacimiento del empleado de recursos humanos
    /// @param _mes_nacimiento mes de nacimiento del empleado de recursos humanos
    /// @param _anio_nacimiento anio de nacimiento del empleado de recursos humanos
    /// @param _email email del empleado de recursos humanos
    /// @param _telefono telefono del empleado de recursos humanos
    function RH_agregarPersonaRH(
        string memory _rfc,
        string memory _nombre,
        string memory _apellido,
        uint _dia_nacimiento,
        uint _mes_nacimiento,
        uint _anio_nacimiento,
        string memory _email,
        string memory _telefono
    ) public {
        if (PermisoRegistroRH_x_RFC[_rfc]==false){
            revert accesoDenegado();
        }
        /// @dev verificamos que el empleado no este registrado
        if (hasRole(EMPLEADO_RH_ROL, msg.sender)) {
            revert EmpleadoRegistrado();
        }
        /// @dev verificamos que el dia y mes no sean cero
        ///      y que el anio sea mayor a 1940
        if (_dia_nacimiento == 0 || _mes_nacimiento == 0 || _anio_nacimiento <= 1940) {
            revert NoCero();
        }
        /// @dev agregamos al empleado de recursos humanos al arreglo

        listaPersonasRH.push(persona(_nombre, _apellido, _dia_nacimiento, _mes_nacimiento, _anio_nacimiento, _email, _telefono, true, 0));
        IndexPersonaRH[_rfc] = listaPersonasRH.length - 1;
        RFC_a_address_RH[_rfc] = msg.sender;
        _setupRole(EMPLEADO_RH_ROL, msg.sender);
    }


    function RH_modificarPersona_email(string memory _rfc, string memory _email) public soloAdmin_o_EmpleadoRH {
        /// @dev se verifica que el empleado este registrado y activo
        if (listaPersonasRH[IndexPersonaRH[_rfc]].dia_nacimiento == 0) {
            revert EmpleadoNoRegistrado();
        }
        if (listaPersonasRH[IndexPersonaRH[_rfc]].estatus == false) {
            revert EmpleadoNoActivo();
        }
        listaPersonasRH[IndexPersonaRH[_rfc]].email = _email;
    }


    function RH_modificarPersona_telefono(string memory _rfc, string memory _telefono) public soloAdmin_o_EmpleadoRH {
        /// @dev se verifica que el empleado este registrado y activo
        if (listaPersonasRH[IndexPersonaRH[_rfc]].dia_nacimiento == 0) {
            revert EmpleadoNoRegistrado();
        }
        if (listaPersonasRH[IndexPersonaRH[_rfc]].estatus == false) {
            revert EmpleadoNoActivo();
        }
        listaPersonasRH[IndexPersonaRH[_rfc]].telefono = _telefono;
    }

    /// @notice funcion que da de baja a un empleado de recursos humanos
    /// @dev esta funcion solo puede ser ejecutada por un administrador
    ///      y da de baja a un empleado de recursos humanos el cual
    ///      ya no podra acceder a este contrato y ademas se le asigna
    ///      la fecha de baja junto con un valor de estatus en falso
    /// @param _rfc rfc del empleado de recursos humanos
    function RH_bajaPersona(string memory _rfc) public soloAdmin {
        /// @dev se verifica que el empleado este registrado y activo
        if (listaPersonasRH[IndexPersonaRH[_rfc]].dia_nacimiento == 0) {
            revert EmpleadoNoRegistrado();
        }
        if (listaPersonasRH[IndexPersonaRH[_rfc]].estatus == false) {
            revert EmpleadoNoActivo();
        }
        listaPersonasRH[IndexPersonaRH[_rfc]].estatus = false;
        listaPersonasRH[IndexPersonaRH[_rfc]].fechaBaja = block.timestamp;
        _revokeRole(EMPLEADO_RH_ROL, RFC_a_address_RH[_rfc]);
    }
    /// @notice funcion que permite recontratar a un empleado de 
    ///         recursos humanos
    /// @dev esta funcion solo puede ser ejecutada por un administrador
    ///      y recontrata a un empleado de recursos humanos el cual
    ///      ya podra acceder a este contrato y ademas se le asigna
    ///      la fecha de baja en cero junto con un valor 
    ///      de estatus en verdadero
    ///      NOTA: solo se puede recontratar a un empleado de recursos
    ///            humanos despues de 30 dias de su baja
    function recontratarPersonaRH(string memory _rfc) public soloAdmin_o_EmpleadoRH {
        /// @dev se verifica que el empleado este registrado y activo
        if (listaPersonasRH[IndexPersonaRH[_rfc]].dia_nacimiento == 0) {
            revert EmpleadoNoRegistrado();
        }
        if (listaPersonasRH[IndexPersonaRH[_rfc]].estatus == true) {
            revert EmpleadoActivo();
        }
        if (listaPersonasRH[IndexPersonaRH[_rfc]].fechaBaja + 2592000 > block.timestamp) {
            revert EmpleadoNoRecontratable();
        }
        listaPersonasRH[IndexPersonaRH[_rfc]].estatus = true;
        listaPersonasRH[IndexPersonaRH[_rfc]].fechaBaja = 0;
        _setupRole(EMPLEADO_RH_ROL, RFC_a_address_RH[_rfc]);
    }
    ////////////////////////////////////////////////////////////////////////////////
    /// @notice funciones para crear areas
    /// @dev fabricas de contratos de areas
    ////////////////////////////////////////////////////////////////////////////////

    /// @notice funcion que genera un contrato de area
    /// @dev esta funcion solo puede ser ejecutada por un administrador
    ///      y genera un contrato de area el cual se agrega a la lista
    ///      de contratos de areas y se le asigna un indice en el arreglo
    ///      y un indice en el arreglo con nombre
    /// @param _codigoArea codigo del area 
    ///                    (para el mapping IndexContratoArea_conNombre)
    /// @param _nombreArea nombre del area del hospital
    /// @dev recuerda que ya tenemos las direcciones de los admins y 
    ///      cuando se genere el contrato de area se asignara como admin
    ///      en el mismo constructor
    //import {Area} from "./Area.sol";
    function agregarArea(string memory _codigoArea,string memory _nombreArea) public soloAdmin returns (address){
        Area aux_AddressArea = new Area(direccionAdmin1, direccionAdmin2, address(this) ,_nombreArea);
        listaContratosAreas.push(address(aux_AddressArea));
        IndexContratoArea[address(aux_AddressArea)] = listaContratosAreas.length - 1;
        IndexContratoArea_conNombre[_codigoArea] = listaContratosAreas.length - 1;
        return address(aux_AddressArea);
    }

    /// @notice funcion que permite modificar el nombre de un area
    /// @dev esta funcion solo puede ser ejecutada por un administrador
    ///      y modifica el nombre de un area
    /// @param _codigoArea codigo del area
    /// @param _nombreArea nuevo nombre del area
    function modificarArea(string memory _codigoArea, string memory _nombreArea) public soloAdmin {
        /// @dev se verifica que el area este registrado usando el address
        //0x000000000
        if (listaContratosAreas[IndexContratoArea_conNombre[_codigoArea]] == address(0)) {
            revert AreaNoRegistrada();
        }
        //                          0xa6hd78dasfhuis
        Area aux_AddressArea = Area(listaContratosAreas[IndexContratoArea_conNombre[_codigoArea]]);
        aux_AddressArea.modificarNombreArea(_nombreArea);
    }

    /// @notice funcion para ver la direccion de un area
    /// @dev esta funcion solo puede ser ejecutada por un administrador
    ///      y regresa la direccion de un area usando el codigo de area
    /// @param _codigoArea codigo del area
    function verDireccionArea(string memory _codigoArea) public view soloAdmin returns (address) {
        /// @dev se verifica que el area este registrado usando el address
        if (listaContratosAreas[IndexContratoArea_conNombre[_codigoArea]] == address(0)) {
            revert AreaNoRegistrada();
        }
        return listaContratosAreas[IndexContratoArea_conNombre[_codigoArea]];
    }

    function AREA_permiteRegistroEmpleado(string memory _codigoArea, string memory _rfc) public soloAdmin_o_EmpleadoRH {
        Area aux_Area = Area(listaContratosAreas[IndexContratoArea_conNombre[_codigoArea]]);
        aux_Area.permiteRegistroEmpleado(_rfc);
    }

    function AREA_agregarEmpleado(
        string memory _codigoArea,
        string memory _rfc,
        string memory _nombre,
        string memory _apellido,
        uint _dia_nacimiento,
        uint _mes_nacimiento,
        uint _anio_nacimiento,
        string memory _email,
        string memory _telefono
    ) public {
        Area aux_Area = Area(listaContratosAreas[IndexContratoArea_conNombre[_codigoArea]]);
        aux_Area.agregarEmpleado(_rfc, _nombre, _apellido, _dia_nacimiento, _mes_nacimiento, _anio_nacimiento, _email, _telefono);
    }

    function AREA_bajaEmpleado(string memory _codigoArea, string memory _rfc) public soloAdmin_o_EmpleadoRH {
        Area aux_Area = Area(listaContratosAreas[IndexContratoArea_conNombre[_codigoArea]]);
        aux_Area.bajaEmpleado(_rfc);
    }

    function AREA_recontratarEmpleado(string memory _codigoArea, string memory _rfc) public soloAdmin_o_EmpleadoRH {
        Area aux_Area = Area(listaContratosAreas[IndexContratoArea_conNombre[_codigoArea]]);
        aux_Area.recontratarEmpleado(_rfc);
    }


}