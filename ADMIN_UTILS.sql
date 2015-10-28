/*Package for creating a new user for an employee*/
-- tables needed for creating a new user 
select * from employees;
select * from app_users
select * from user_atributions where we will insert a role selected from role_types;
select * from user_credentials 


create or replace package ADMIN_UTILS as
  -- admin procedure for registering new accounts.
  procedure create_new_user(p_user_name varchar2, p_password varchar2, p_department varchar2);
end ADMIN_UTILS;

create or replace package body ADMIN_UTILS as
  procedure
  procedure create_new_user(pnew_emp in new_employee_type) as
    
  begin
    
    null;
  end;

end;
