// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Batch {
    error NotAuthorized();
    error NotEnoughFunds();
    error TransactionFailed();

    address public owner;
    mapping(address => uint256) public employeesSalaries;
    address[] public employees;

    event EmployeePaid(address indexed employee, uint256 amount);
    event EmployeeAdded(address indexed employee, uint256 amount);
    event EmployeeRemoved(address indexed employee, uint256 amount);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert NotAuthorized();
        }
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addEmployee(
        address _employee,
        uint256 _salary
    ) external onlyOwner {
        employees.push(_employee);
        employeesSalaries[_employee] = _salary;
        emit EmployeeAdded(_employee, _salary);
    }

    function removeEmployee(address _employee) external onlyOwner {
        for (uint256 i = 0; i < employees.length; i++) {
            if (employees[i] == _employee) {
                employees[i] = employees[employees.length - 1];
                employees.pop();

                uint256 _salary = employeesSalaries[_employee];
                delete employeesSalaries[_employee];
                emit EmployeeRemoved(_employee, _salary);

                break; // break out of the loop
            }
        }
    }

    function payEmployees() external onlyOwner {
        for (uint256 i = 0; i < employees.length; i++) {
            address employee = employees[i];
            uint256 salary = employeesSalaries[employee];

            if (address(this).balance < salary) {
                revert NotEnoughFunds();
            }

            (bool success, ) = payable(employee).call{value: salary}(""); // returns if transfer is successful

            if (!success) {
                revert TransactionFailed();
            }

            emit EmployeePaid(employee, salary);
        }
    }

    function depositFunds() external payable onlyOwner {}

    function getEmployeesList() external view returns (uint256) {
        return employees.length;
    }

    function getOwnersBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getEmployeesSalaries(
        address _employee
    ) external view returns (uint256) {
        return employeesSalaries[_employee];
    }
}
