select * from user_tables;
select * from request_types;
select * from APP_USERS;
select * from requests for update;

-- db data insert for simple web tests
insert into request_types(type_id, req_code, active, requires_flux) values (1, 'MEDICAL_LEAVE', 'D', 'N');
insert into request_types(type_id, req_code, active, requires_flux) values (2, 'VACATION_LEAVE', 'D', 'D');
insert into request_types(type_id, req_code, active, requires_flux) values (3, 'CULTURAL_HOLIDAY', 'D', 'N');
insert into request_types(type_id, req_code, active, requires_flux) values (4, 'UNPAID_LEAVE', 'D', 'D');


Select * from user_tables;



create or replace package AC_req_actions(
  procedure insert_request(); -- parameters are yet to be determined 
  procedure delete_request();
  procedure update_request();
  function check_in_role() return varchar2;
  function validate_period(p_start_date date, p_end_date date, pdept varchar) return varchar2; -- checks to see if undelying constraints have not been violated
  procedure contains_legal_holidays(start_d date, end_d date, how_many out number); -- we check if interval contains legal holidays and use the out to calculate total number of days 
);

select * from employees
select * from requests;
create or replace package body AC_req_actions() as
  -- variabile de pachet
  poate_insera boolean;
  este_admin boolean;
  exm varchar2(500);
  
  function validate_period(p_start_date date, p_end_date date, pdept varchar) as
      -- we search for how many days of the interval are already covered 
    cursor c_accepted_no is 
      select no_of_res from departments dp where dp.code = pdept;
    cursor c_already_approved is
      select * from requests rq 
        where (select dp. from departments dp ) 
          and (rq.start_date <= p_start_Date or rq.end_date >= p_end_date)
              
  begin
    
     
  exception
    when no_data_found then
      exm := substr(sqlerrm, 1, 500);
        raise_application_error(-20150, exm);   
  end validate_period;

  procedure insert_request(p_l_type varchar, p_start_date varchar2, p_end_date varchar2, p_app_user varchar2, p_dept varchar2, pout_msg out varchar2) as
    v_max_no number;
    v_days_to_date number;
    total_days number;
    select * from requests for update;
    -- cursors for retreiving/calculating data based on form input 
    cursor c_has_days_left is
      
        
  begin
    -- we calculate the total number of days within the inverval
    total_days :=   
    -- we calculate the remaining number of days
    begin
      select max_no_days into v_max_no  from days_per_year dpy
          where req_code = p_l_type;   
      select da.total_no_days into v_days_to_date from  days_accorded da 
        join requests rq on rq.id = da.req_id
          where rq.acc_id = (select au.id from app_users au where au.code = p_app_user)
      exception
        when no data found then
          p_out_msg := substr(sqlerrm, 1, 500);
      end;    
      
    if ((v_max_no - v_days_to_date) < (trunc(p_end_date) - trunc(p_start_date)) and p_out_msg is null) then          
      pout_msg := 'Too few days left';        
    else 
          insert into requests
            (id,
             type_of_req,
             status,
             acc_id,
             dept_id,
             start_date,
             end_date,
             total_no_of_days,
             validated,
             val_date,
             val_user_code,
             resolved,
             res_user,
             rejected,
             rejected_user_code)
          values
            ( REQ_ID_SEQ.NEXTVAL,
              pid_type_req,
              'SUBMIT',
              (select au.id from app_users au where au.code = p_app_user),
              (select emp.dept_id from employees emp where emp.id = (select emp_id from app_users where code = p_app_user)),
              <start_date_WEB_param>,
              <end_date_WEB_param>,
              <calculated end -start>, 
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
      pout_msg := substr(sqlerrm, 1, 500);           
  end insert_request;  
end AC_req_actions;
select * from user_sequences;
select * from requests;
