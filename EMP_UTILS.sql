/*This package will contain all standard actions that need to be performed on the employee table
 - insert
 - update
 - delete
 - get_all_employees in a department -> returns a collection
*/

select * from employees;
create or replace package EMP_UTILS as 
  procedure insert_employee(p_f_name varchar2, p_l_name varchar2, p_email varchar2, p_hire_date date, p_dep number, trial_period varchar2 );
  procedure delete_employee(p_f_name varchar2, p_l_name varchar2, p_email varchar2);
  -- we overload the above function so we can delete based only on employee ID
  procedure delete_employee(p_emp_id number);
end EMP_UTILS;

create or replace package body EMP_UTILS as 


end emp_utils;


end EMP_UTILS;
