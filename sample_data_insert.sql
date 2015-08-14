select * from user_tables;
select * from request_types;
select * from APP_USERS;
select * from requests for update;
select * from departments;
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

truncate table requests;
Select * from user_tables;
--##--------------------
-- This procedure will return a specific type that will have the following structure 
-- 
-- 12 MONTH -> list of days -> list of users approved in that day
create or replace procedure get_req_general_status() as

begin


end;

create or replace package ADMIN_UTILS as 
  -- admin procedure for registering new accounts.
  procedure create new_user(p_user_name varchar2, p_password varchar2, p_department varchar2);
end ADMIN_UTILS;

create or replace package AC_req_actions as
  procedure insert_request(p_l_type varchar, p_start_date varchar2, p_end_date varchar2, p_app_user_id varchar2, p_dept_id number, p_out_msg out varchar2); -- parameters are yet to be determined
/*  procedure delete_request;
  procedure update_request;
  function check_in_role return varchar2;*/
end AC_req_actions;

create or replace package body AC_req_actions as
  -- variabile de pachet
  poate_insera boolean;

  este_admin boolean;
  function num_days_in_interval(pst_date date, pend_Date date) return number as
    -- we choose all legal days that are not in a weekend
    cursor c_legal_day is
      select legal_date from legal_days ld
        where ld.in_year = to_char(sysdate,'YYYY')
          and (MOD(TO_CHAR(legal_date, 'J'), 7) + 1 NOT IN (6, 7));
    init_number number;
	  curr_Date date; -- cursor date that we use to go through the interval
    err_m varchar2(500);
  begin
   -- we calculate the default number of days between the interval
    select (trunc(pend_date + 1) - trunc(pst_date)) into init_number from dual;
     dbms_output.put_line('starting point ->' || init_number);
    curr_date := pst_Date;
    -- we firstly exclude weekend days if there are any
    loop
       --dbms_output.put_line('data -> ' || curr_date);
      if (MOD(TO_CHAR(curr_date, 'J'), 7) + 1 IN (6, 7)) then
        init_number := init_number -1;
        /*dbms_output.put_line('este weekend');*/
      end if;
      curr_date := curr_date+1;
      exit when curr_date > pend_date;
    end loop;
    -- now we exclude legal days that have already been checked for weekend overlap
    for x in c_legal_day loop
      if ((x.legal_date >= pst_date) and (x.legal_date <= pend_date)) then
        init_number := init_number - 1;
      end if;
    end loop;

    return init_number;
  exception
    when others then
      err_m := substr(sqlerrm, 1, 500);
      raise_application_error(-20150, err_m);
  end num_days_in_interval;

  function validate_period(p_st_date date, p_end_date date, pdpt_id number) return varchar2 as
      -- we search for how many days of the interval are already covered
    rez varchar2(60);
    existing_req_per_int number;
    accepted_final_no number;
    reserves number;
    deficit number;
    exm varchar2(500);
  begin
    existing_req_per_int := 0;
    for k in (select * from requests rq where rq.resolved = 'D' and rq.dept_id  = pdpt_id and (trunc(rq.start_date) <= trunc(p_st_date) or trunc(rq.end_date) >= trunc(p_end_date))) loop
      -- for each req overlapped we increase the counter
      existing_req_per_int := existing_req_per_int + 1;
    end loop;
    -- we calculate the total number of accepted people on leave per dept
    begin
      select dp.no_of_res, dr.accepted_deficit
        into reserves, deficit
        from departments dp
        join dept_requirements dr
          on dp.code = dr.code
       where dp.dep_id = pdpt_id;
    exception
      when no_data_found then
        rez := 'No Such department';
        return rez;
    end;
    accepted_final_no := reserves + deficit;
    if (accepted_final_no < (existing_req_per_int + 1)) then
      rez := 'OK';
      return rez;
    else
      rez := 'Overlap beyond accepted number';
      return rez;
    end if;
  exception
    when no_data_found then
      exm := substr(sqlerrm, 1, 500);
        raise_application_error(-20155, exm);
  end validate_period;

  procedure insert_request(p_l_type varchar, p_start_date varchar2, p_end_date varchar2, p_app_user_id varchar2, p_dept_id number, p_out_msg out varchar2) as
    v_max_no number;
    v_days_to_date number;
    v_dept_id number;
    total_days number;
    cnt number;
    
  begin
    -- we calculate the remaining number of days
    begin
      select emp.dep_id
        into v_dept_id
        from employees emp
       where emp.emp_id =
             (select emp_id from app_users where  id = p_app_user_id);
      v_days_to_date := 0;
      select dpy.max_no_days
        into v_max_no
        from days_per_year dpy
       where req_code = p_l_type;
      -- We calculated how many days he has from the begining of the year and until sysdate
      for k in(
        select r.total_no_of_days
          from requests r
         where r.acc_id = p_app_user_id
           and r.validated = 'D'
           and r.resolved = 'D'
           and r.dept_id = p_dept_id)
      loop
        cnt := k. total_no_of_days;
        v_days_to_date :=  v_days_to_date + cnt;
      end loop;
    exception
      when others then
        p_out_msg := 'problema in calcul nr zile -> ' || substr(sqlerrm, 1, 450);
    end;
    -- we calculate the total number of days within the inverval
    dbms_output.put_line('Am trecut de primul if');
    total_days :=  num_days_in_interval(p_start_date, p_end_date);  
    if (((total_days + v_days_to_date) > v_max_no) and p_out_msg is null) then
      p_out_msg := 'Too few days left';
      dbms_output.put_line('Am trecut de if');
    else
          insert into requests
              (id,
               type_of_req,
               status,
               submition_date,
               acc_id,
               dept_id,
               start_date,
               end_date,
               total_no_of_days,
               validated,
               val_date,
               val_user,
               resolved,
               res_user,
               rejected,
               rejected_user)
            values
              ( REQ_ID_SEQ.NEXTVAL,
                p_l_type,
                'SUBMIT',
                trunc(sysdate),
                (select au.id from app_users au where au.code = p_app_user_id),
                v_dept_id,
                p_start_date,
                p_end_date,
                total_days,
                'N',
                null,
                null,
                'N',
                null,
                'N',
                null);
    end if;
  exception
    when others then
      p_out_msg := 'Este in forul cel mare ' || substr(sqlerrm, 1, 450);
  end insert_request;
end AC_req_actions;
