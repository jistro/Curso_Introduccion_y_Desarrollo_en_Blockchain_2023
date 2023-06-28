// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

/// @title sistema de registro y control de personal de una area 
/// @author jistro.eth
/// @notice este contrato permite el registro de personal de una area
///         desde el contrato principal, asi como la edicion de datos
///         y la baja/alta de personal
/// @dev este contrato es usado por el contrato principal para el registro
///      de personal, ya que Principal.sol es una fabrica de contratos
///      de tipo Area.sol
/// @custom:experimental este contrato es experimental solo para fines educativos



/// @dev importamos la libreria de openzeppelin para el manejo de roles
import "@openzeppelin/contracts/access/AccessControl.sol";

error SoloAdmin();
error FueraDeTiempoContrato();
error EmpleadoNoRegistrado();
error EmpleadoRegistrado();
error EmpleadoNoActivo();
error EmpleadoActivo();
error NoCero();
error accesoDenegado();

contract Area is AccessControl {
    bytes32 public constant ADMIN_ROL = keccak256("ADMIN_ROL");
    bytes32 public constant EMPLEADO_ROL = keccak256("EMPLEADO_ROL");
    bytes32 public constant CONTRATO_PRINCIPAL = keccak256("CONTRATO_PRINCIPAL");
    /*
    usuario -> contrato -> contrato2
    0x123       0xabc       0xghj
    */
    string  public nombreArea;
    address immutable public direccionArea;
    constructor(address _admin1, address _admin2,address _contratoPrincipal, string memory _nombreArea) {
        _setupRole(ADMIN_ROL, _admin1);
        _setupRole(ADMIN_ROL, _admin2);
        _setupRole(CONTRATO_PRINCIPAL, _contratoPrincipal);
        nombreArea = _nombreArea;
        direccionArea = address(this);
    }

    modifier soloAdmin() {
        if ( !  ( hasRole(ADMIN_ROL, msg.sender) || hasRole(CONTRATO_PRINCIPAL, msg.sender) ) ) {
            revert SoloAdmin();
        }
                    _;
    }

    struct empleado {
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

    empleado[] public listaEmpleados;

    /// @dev mapeo para buscar empleado por rfc 
    mapping(string => uint) public IndexEmpleado_RFC;
    mapping(address => uint) public IndexEmpleado;

    mapping (string =>bool) public PersmisoRegistro_x_RFC;

    function modificarNombreArea(string memory _nombreArea) public soloAdmin {
        nombreArea = _nombreArea;
    }

    function permiteRegistroEmpleado(string memory _rfc) public soloAdmin{
        PersmisoRegistro_x_RFC[_rfc] = true;
    }



    function agregarEmpleado(
        string memory _rfc,
        string memory _nombre,
        string memory _apellido,
        uint _dia_nacimiento,
        uint _mes_nacimiento,
        uint _anio_nacimiento,
        string memory _email,
        string memory _telefono
    ) public {
        if (PersmisoRegistro_x_RFC[_rfc] == false) {
            revert accesoDenegado();
        }
        if (hasRole(EMPLEADO_ROL, msg.sender)) {
            revert EmpleadoRegistrado();
        }
        /// @dev verificamos que el dia y mes no sean cero
        ///      y que el anio sea mayor a 1940
        if (_dia_nacimiento == 0 || _mes_nacimiento == 0 ) {
            revert NoCero();
        }
        listaEmpleados.push(empleado(_nombre, _apellido, _dia_nacimiento, _mes_nacimiento, _anio_nacimiento, _email, _telefono, true, 0));
        IndexEmpleado[msg.sender] = listaEmpleados.length - 1;
        IndexEmpleado_RFC[_rfc] = listaEmpleados.length - 1;
        _setupRole(EMPLEADO_ROL, msg.sender);
    }
    

    function verEmpleado() public view returns (string memory, string memory, string memory, string memory, bool){
        return (
            listaEmpleados[IndexEmpleado[msg.sender]].nombre,
            listaEmpleados[IndexEmpleado[msg.sender]].apellido,
            listaEmpleados[IndexEmpleado[msg.sender]].email,
            listaEmpleados[IndexEmpleado[msg.sender]].telefono,
            listaEmpleados[IndexEmpleado[msg.sender]].estatus
        );
    } 

    function editarEmpleado_email( string memory _rfc, string memory _nuevoCorreo) public soloAdmin{
        if (listaEmpleados[IndexEmpleado_RFC[_rfc]].dia_nacimiento == 0) {
            revert EmpleadoNoRegistrado();
        }
        if (listaEmpleados[IndexEmpleado_RFC[_rfc]].estatus == false) {
            revert EmpleadoNoActivo();
        }
        listaEmpleados[IndexEmpleado_RFC[_rfc]].email = _nuevoCorreo;
    }

    function editarEmpleado_telefono( string memory _rfc, string memory _nuevoTelefono) public soloAdmin{
        if (listaEmpleados[IndexEmpleado_RFC[_rfc]].dia_nacimiento == 0) {
            revert EmpleadoNoRegistrado();
        }
        if (listaEmpleados[IndexEmpleado_RFC[_rfc]].estatus == false) {
            revert EmpleadoNoActivo();
        }
        listaEmpleados[IndexEmpleado_RFC[_rfc]].telefono = _nuevoTelefono;
    }

    function bajaEmpleado(string memory _rfc) public soloAdmin {
        if (listaEmpleados[IndexEmpleado_RFC[_rfc]].dia_nacimiento == 0) {
            revert EmpleadoNoRegistrado();
        }
        if (listaEmpleados[IndexEmpleado_RFC[_rfc]].estatus == false) {
            revert EmpleadoNoActivo();
        }
        listaEmpleados[IndexEmpleado_RFC[_rfc]].estatus = false;
        listaEmpleados[IndexEmpleado_RFC[_rfc]].fechaBaja = block.timestamp;
    }

    //podemos recontratar empleado pasado 30 dias de baja
    function recontratarEmpleado(string memory _rfc) public soloAdmin {
        if (listaEmpleados[IndexEmpleado_RFC[_rfc]].dia_nacimiento == 0) {
            revert EmpleadoNoRegistrado();
        }
        if (listaEmpleados[IndexEmpleado_RFC[_rfc]].estatus == true) {
            revert EmpleadoActivo();
        }
        if (listaEmpleados[IndexEmpleado_RFC[_rfc]].fechaBaja + 30 days <= block.timestamp) {
            revert FueraDeTiempoContrato();
        }
        listaEmpleados[IndexEmpleado_RFC[_rfc]].estatus = true;
        listaEmpleados[IndexEmpleado_RFC[_rfc]].fechaBaja = 0;
    }
}