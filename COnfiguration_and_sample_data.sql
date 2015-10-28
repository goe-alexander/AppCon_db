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
 --   The only viable region agnostic alternative to determine if it is a weekday is:
  MOD(TO_CHAR(my_date, 'J'), 7) + 1 IN (6, 7); -- it calculates the JULIAD DATES (all days since 4712 BC) divides by 7 and the mod is added 1  
-- ### ---------------------------------------  
-- script for verifying which legal deay is on a weekend;

begin
  for x in (select legal_date from legal_days ld where ld.in_year = to_char(sysdate, 'YYYY')) loop
    if(MOD(TO_CHAR(x.legal_date, 'J'), 7) + 1 IN (6, 7)) then
      dbms_output.put_line('This date is on the weekend -> ' || x.legal_date);
    end if;
  end loop;
end;


