
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
-- ##----------------------------------------
create table a as
with calendar as (
        select ((&startdate + rownum) - 1) as day
        from dual
        connect by rownum < &enddate - startdate
    )
select rownum as "S.No", to_date(day,'dd_mm_yyyy') as "Cal_Dt", to_char(day,'day') as "DayName"
from calendar
---###------------------------------------------
create or replace procedure clear_All_tb_in_db as
  i number;
begin
i:=0;
  for x in (select table_name from user_tables) loop
    execute immediate 'drop table ' || x.table_name;
    i := i+1;
    dbms_output.put_line('Dropped table: ' || x.table_name);
  end loop;
  dbms_output.put_line('Nr tabele sterse: ' || i);
end;


-- Structure declarations
--## Seing as this is an internal application there will not be any registration process through which accounts are created. 
--## They will be entered by admin or in future a registration option will be added. 
select * from user_tables;
drop table requests
select * from user_tables;
select * from departments
select * from dept_requirements for update;
select * from legal_days for update;
SELECT * FROM DAYS_PER_YEAR FOR UPDATE;
select * from DEPARTMENTS for update 
select * from employees for update;
select * from user_accounts for update;
select * from REQUEST_TYPES for update;
select * from user_accounts;
select * from app_users for update;
-- based on this table alone we can develop a select
-- we create a table for mapping all legal days 
create table legal_days(
  legal_date date,
  in_year varchar2(10),
  constraint pk_leg_days primary key (legal_date, in_year)
);
select * from app_users;

create table user_credentials(
  user_nm varchar2(60),
  pass_word varchar2(256),
  constraint fk_usr_nm_cred foreign key (user_nm) references app_users(code)
); 

create table user_atributions(
  user_id number(10),
  role_id number(10),
  foreign key (user_id) references app_users(id),
  foreign key (role_id) references role_types(role_id)
);

create table role_types(
  role_id number(10),
  role_code varchar2(30),
  role_description varchar2(60),
  active varchar2(1) default 'D',
  constraint pk_rol_id primary key (role_Id) ,
  constraint chck_is_actv check (active in ('D', 'N')) 
  
);
create sequence role_types_seq
          start with 1
          increment by 1
          NOCYCLE
          NOCACHE;
drop table user_accounts;
create table user_accounts(
  user_id number(10) primary key,
  code varchar2(30) unique,
  active varchar2(30) default 'D',
  manager varchar2(30) default 'N',
  admin varchar2(30) default 'N',
  constraint chk_active_acc check(active in ('D','N')),
  constraint chk_manager_acc check(manager in ('D','N')),
  constraint chk_admin_acc check(admin in ('D','N'))
);
select * from requests for update;

drop table requests;
desc requests;
create table requests(
  id number(10) primary key,
  type_of_req varchar2(60),
  Status varchar2(60),
  submition_date date, 
  Acc_id number, -- initiator
  dept_id number,
  start_date date,
  end_date date, 
  total_no_of_days number(10),
  validated varchar2(1) default 'N',
  val_date date,
  val_user varchar2(30),
  Resolved varchar(1) default 'N',
  res_user varchar2(30),
  rejected varchar2(1) default 'N',
  rejected_user varchar2(30)
);
create sequence req_id_seq
        start with 1
        increment by 1
        NOCYCLE
        NOCACHE;
create index idx_req_type_of on requests(type_of_req);
create index idx_req_status on requests(Status);
create index idx_req_acc_id on requests(Acc_id);
create index idx_req_total_days on requests(total_no_of_days);

--- ### These two tables represent the different states that a req may be in as well as the rule of from one state through the other
create table Possible_status_change(
  current_state varchar2(30),
  future_state varchar2(30),
  constraint fk_curr_state foreign key(current_state) references status_types(stat_code) on delete cascade,
  constraint fk_future_state foreign key(future_state) references status_types(stat_code) on delete cascade
);


select * from struct_table;

create table status_types(
  stat_code varchar2(60) primary key,
  description varchar2(30),
  active varchar2(1)
);
create sequence stat_type_seq
  start with 1
  increment by 1
  NOCACHE
  NOCYCLE;

---###
create table activities(
  act_id number primary key,
  act_code varchar2(60),
  rezolved varchar2(1),
  anulled varchar2(1) default 'N', -- anulled 
  in_execution varchar2(1),
  
);
create index on activities(act_code);
create or replace sequence activities_id_generator
  start with 1 
  increment by 1
  NOcache
  nocycle;
--- 

---
drop table request_types;
create table legal_holidays(
  month number,
  date_h date,
  active default 'D'  
  );



create table request_types(
  type_id number,
  req_code varchar2(60),
  req_description varchar2(60),
  active varchar2(1),
  requires_flux varchar2(1) default 'N',
  constraint pk_req_code primary key(req_code),
  constraint chck_active_req check (active in ('D','N')),
  constraint chck_necesita_flux check(requires_flux in ('D', 'N'))
);
create index idx_req_type_code on request_types(req_code);
create sequence req_type_generator
  start with 1 
  increment by 1
  NOcache
  nocycle; 
---
create table days_per_year(
  req_code varchar2(60),
  max_no_days number(10),
  constraint uq_req_no_days unique (req_code, max_no_days)  
);

create index idx_days_req_code on days_per_year(req_code);
--
create table dept_requirements(
  code varchar2(60),
  start_date date,
  end_date date,
  required_people number,
  accepted_deficit number
);
drop table dept_requirements;
create table app_users(
  id number,
  code varchar2(60),
  emp_id number(10),
  Active varchar2(1) default 'D', 
  constraint uq_id_col Unique(id),
  constraint pk_usr_nm_code primary key (code),
  constraint fk_emp_id foreign key (emp_id) references employees(emp_id),
  constraint ck_activ_in_val check (active in ('D', 'N'))
);

create table employees(
  emp_id number primary key,
  f_name varchar2(60),
  l_name varchar2(60),
  email varchar2(60),
  hire_date date,
  TM_id number,
  dep_id number,
  constraint fk_manager_id foreign key (tm_id) references employees(emp_id),
  constraint fk_dept_id foreign key (dep_id) references departments(dep_id)
);

create table departments(
  dep_id number(18) primary key,
  code varchar2(60),
  active varchar2(1) default null,
  no_of_emplyees varchar2(60),
  no_of_main_emp number(30),
  no_of_res number(30),
  tm_id number(30),
  constraint check_activ_dep check (active in ('D', 'N') ),
  constraint fk_tm_id foreign key(tm_id) references employees(emp_id)
 );

create table participants(
  id_part number primary key,
  user_name foreign key dk_us_nm_part,
  active varchar2(1) check in ('D','N'),
  emp_id foreign key 
  dep_id
);

drop table contracts;
create table contracts(
  id number(30),
  emp_id number, 
  length_in_months number,
  trial_period varchar2(1) ,
  constraint pk_id_contract primary key(id),
  constraint fk_emp_id_contr foreign key (emp_id) references employees(emp_id),
  constraint chck_trial_period check(trial_period is not null),
  constraint chck_tr_per_possible_values check(trial_period in ('D', 'N'))
);
-- table used to calculate attributed days for new employees or those emp who are on trial period. 
create table days_per_month(
  req_code varchar2(30),
  no_of_days number(10),
  constraint fk_req_day_p_month foreign key(req_code)references request_types(req_code)
);
create public synonym days_per_month for days_per_month;
