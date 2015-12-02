-- inserts for configurable datatypes;
-- db data insert for simple web tests
insert into request_types(type_id, req_code, active, requires_flux) values (1, 'MEDICAL_LEAVE', 'D', 'N');
insert into request_types(type_id, req_code, active, requires_flux) values (2, 'VACATION_LEAVE', 'D', 'D');
insert into request_types(type_id, req_code, active, requires_flux) values (3, 'CULTURAL_HOLIDAY', 'D', 'N');
insert into request_types(type_id, req_code, active, requires_flux) values (4, 'UNPAID_LEAVE', 'D', 'D');

-- User Role inserts

insert into role_types(role_id, role_code, role_description, active) values(role_types_seq.nextval, 'ADMIN', 'Administrator, Bo$$', 'D');
insert into role_types(role_id, role_code, role_description, active) values(role_types_seq.nextval, 'PROJECT_MANAGER', 'Responsible of organization', 'D');
insert into role_types(role_id, role_code, role_description, active) values(role_types_seq.nextval, 'TEAM_LEAD', 'Head of team', 'D');
insert into role_types(role_id, role_code, role_description, active) values(role_types_seq.nextval, 'HR', 'Human Resources', 'D');
insert into role_types(role_id, role_code, role_description, active) values(role_types_seq.nextval, 'USER', 'Pawn', 'D');
-- block for clearing all database tables:
/*create or replace procedure clear_All_tb_in_db as
  i number;
begin
i:=0;
  for x in (select table_name from user_tables) loop
    execute immediate 'drop table ' || x.table_name;
    i := i+1;
    dbms_output.put_line('Dropped table: ' || x.table_name);
  end loop;
  dbms_output.put_line('Nr tabele sterse: ' || i);
end;*/
-- ## Setting department requirements
select * from dept_requirements;
begin
  for k in ( select dp.code, dp.no_of_emplyees from departments dp) loop
    insert into dept_requirements(code, start_date, end_date, required_people, accepted_deficit)
      values (k.code,  to_date('06/01/2015', 'MM/DD/YYYY'), to_date('06/30/2015','MM/DD/YYYY'), k.no_of_emplyees, 1);
  end loop;
end;
-- INSERTING LEGAL DAYS ---------------------
select * from legal_days
 --   The only viable region agnostic alternative to determine if it is a weekend day is:
  MOD(TO_CHAR(my_date, 'J'), 7) + 1 IN (6, 7); -- it calculates the JULIAD DATES (all days since 4712 BC) divides by 7 and the mod is added 1  then checked if it is 6 or 7
-- ### ---------------------------------------  
-- script for verifying which legal deay is on a weekend;

begin
  for x in (select legal_date from legal_days ld where ld.in_year = to_char(sysdate, 'YYYY')) loop
    if(MOD(TO_CHAR(x.legal_date, 'J'), 7) + 1 IN (6, 7)) then
      dbms_output.put_line('This date is on the weekend -> ' || x.legal_date);
    end if;
  end loop;
end;


### role insertion and definition
insert into employees(emp_id, f_name, l_name, email, hire_date, tm_id, dep_id) values (4, 'M', 'SEF', 'M.sef@gmail.com', sysdate, null, 7);
insert into user_credentials(user_nm, pass_word) values('M.SEF', '********');
insert into user_credentials(user_nm, pass_word) values('ADMIN', '********');
insert into user_credentials(user_nm, pass_word) values('GOE.ALEX', '********');
insert into user_credentials(user_nm, pass_word) values('GOE.USER', '********');

insert into app_users(id, code, emp_id, active) values(3, 'MARIUS.SEF', 4, 'D'); 
select * from user_tables;
select * from user_atributions;
select * from role_types;
select * from role_types;
select * from user_credentials;
truncate table user_credentials;
insert into user_atributions(user_id, role_id) values(0,1);
insert into user_atributions(user_id, role_id) values(1,3);
insert into user_atributions(user_id, role_id) values(2,5);
insert into user_atributions(user_id, role_id) values(3,2);




select rt.role_code from user_atributions ua
                      join role_types rt on ua.role_id = rt.role_id
                      where ua.user_id = (select au.id from app_users au where au.code = upper('GOE.ALEX'))
    
Select 1 from user_credentials uc where upper(uc.user_nm) = 'admin' and uc.pass_word = ?

----
-- Insertion of New Errors to be shown to the client
select * from sl_errors;
insert into sl_errors(cod_err, err_description, active) values(1, 'Problems identifying role','D');
insert into sl_errors(cod_err, err_description, active) values(2, 'Issue in retrieving requests for $1', 'D');
insert into sl_errors(cod_err, err_description, active) values(3, 'Problems identifying role', 'D');
insert into sl_errors(cod_err, err_description, active) values(4, 'Part of that interval ', 'D');
insert into sl_errors(cod_err, err_description, active) values(3, 'You have pending Vacation requests that are unresolved.', 'D');
