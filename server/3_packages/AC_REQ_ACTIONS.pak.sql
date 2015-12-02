/* Package that contains all available actions on a request as well as 
  procedures to determine which actions are available on which request 
  based on user role and start date of each vaction leave
*/
create or replace package AC_req_actions as
  type t_overlap_day is record(
    day_overlapped number,
    month_of_day varchar2(20)
  );
  type col_overlapped_days is table of t_overlap_day;
  function is_working_day(pdate date) return boolean;
  procedure insert_request(p_l_type varchar, p_start_date varchar2, p_end_date varchar2, p_app_user_id varchar2, p_dept_id number, p_total_days number, p_out_msg out varchar2); 
  function num_days_in_interval(pst_date date, pend_Date date) return number;
  procedure delete_this_request(pid_req number, pacc_id number);
  procedure update_this__request(pid_req number, pacc_Id number, p_upd_stmt varchar2);
  function pending_vacation_req(pacc_Id number, pdept_id number ) return boolean;
  -- used by web to call before inserting any request we have to validate there is no overlap
  function validate_period(p_st_date date, p_end_date date, pdpt_id number) return varchar2;
  -- this function will return a special type that has the details of every request for a specified department. 
  --function calculate_available_actions();
  
    function get_overlapped_days(p_st_date date, p_end_date date, p_dept_id number) return col_overlapped_days;
end AC_req_actions;

create or replace package body AC_req_actions as
  function is_working_day(pdate date) return boolean as 
    rez boolean;
    -- all legal free days that are not weekend
    cursor c_get_legal_days is 
      select legal_date from legal_days ld
        where ld.in_year = to_char(sysdate,'YYYY')
          and (MOD(TO_CHAR(legal_date, 'J'), 7) + 1 NOT IN (6, 7))
          and ld.legal_date = pdate;
    cgl c_get_legal_days%rowtype;      
  begin
    rez := true; 
    -- check if it's weekend 
    open c_get_legal_days;
    fetch c_get_legal_days into cgl;
    if c_get_legal_days%notfound then 
      if (MOD(TO_CHAR(pdate, 'J'), 7) + 1 IN (6, 7)) then  
        rez := false;   
      end if;
    else 
      rez := false;
    end if; 
    return rez;
  end;
  
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
  
  --#### This function will be called from backing bean once remaining days and taken days are calculated
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
    for k in (select * from requests rq where rq.resolved = 'D' and rq.dept_id  = pdpt_id and (trunc(rq.start_date) <= trunc(p_end_date) and trunc(rq.end_date) >= trunc(p_st_date))) loop
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
      rez := 'Overlap beyond accepted number, all reserves are on Holiday in that period.';
      return rez;
    end if;
  exception
    when no_data_found then
      exm := substr(sqlerrm, 1, 500);
        raise_application_error(-20155, exm);
  end validate_period;

  procedure insert_request(p_l_type varchar, p_start_date varchar2, p_end_date varchar2, p_app_user_id varchar2, p_dept_id number, p_total_days number, p_out_msg out varchar2) as
    pending_req boolean;
    v_acc_id number;
  begin
    begin
  	  select au.id into v_acc_id from app_users au where au.code = p_app_user_id;
    exception
      when no_data_found then
        p_out_msg := 'Did not find used account code';
        return;
    end;
    pending_req := false;
    /*  if this point is reached then all values have been calculated and that means the minimum requirements have been fullfilled
      All that remains is to check wether there are no overlaps on the schedule.*/
    if p_l_type = 'VACATION_LEAVE'  then
      pending_req := pending_vacation_req(v_acc_id, p_dept_id);
      --  if it's a vacatin req and there is no overlap and no pending req then we insert a new request
      if(pending_req = false) then
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
               resolved,
               res_user,
               rejected,
               rejected_user,
               under_review
               )
            values
              ( REQ_ID_SEQ.NEXTVAL,
                p_l_type,
                'SUBMIT',
                trunc(sysdate),
                v_acc_id,
                p_dept_id,
                p_start_date,
                p_end_date,
                p_total_days,
                'N',
                null,
                'N',
                null,
                'N');
      else
        p_out_msg := 'You have pending Vacation requests that are unresolved';           
      end if;
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
               resolved,
               res_user,
               rejected,
               rejected_user,
               under_review
               )
            values
              ( REQ_ID_SEQ.NEXTVAL,
                p_l_type,
                'SUBMIT',
                trunc(sysdate),
                (select au.id from app_users au where au.code = p_app_user_id),
                p_dept_id,
                p_start_date,
                p_end_date,
                p_total_days,
                'N',
                null,
                'N',
                null,
                'N');
    end if;
  exception
    when others then
      p_out_msg := substr(sqlerrm, 1, 500);
  end insert_request;

  procedure delete_this_request(pid_req number, pacc_id number) is
    --  no need for additional checks here as we will have a procedure that calculates all of the possible actions on a request
    errm varchar2(500);
    PARAMTERII_NULI exception;
  begin
    if (pid_req is not null and pacc_id is not null)then
      delete requests rq where rq.id = pid_req and rq.acc_id = pacc_id;
    else
      raise PARAMTERII_NULI;
    end if;
  exception
    when PARAMTERII_NULI then
      raise_application_error(-20155, 'Could not determine which request to delete');
    when others then
      errm := substr(sqlerrm, 1, 500);
      raise_application_error(-20154, 'Error deleting request: ' || errm);
  end;
  procedure update_this__request(pid_req number, pacc_Id number, p_upd_stmt varchar2) is
    --  no need for additional checks here as we will have a procedure that calculates all of the possible actions on a request
    errm varchar2(500);
  begin
      EXECUTE IMMEDIATE p_upd_stmt;
  exception
    when others then 
      errm := substr(sqlerrm, 1, 500);
      raise_application_error(-20157, 'Error in updating request: ' || errm);    
  end;

  function pending_vacation_req(pacc_Id number, pdept_id number) return boolean as

    /*This function will return true if there are any pending requests in their final stage so
    that an employee may not make another vacation request. THis will be called from within the insert req procedure
    ## */
    -- we search for all unprocessed requests that are not retroactive and are from the year in question
    cursor c_get_pend_vac_leave is
      select count(*)
        from requests rq
       where rq.status <> 'RESOLVED'
         and rq.is_retroactive = 'N'
         and rq.resolved = 'N'
         and rq.rejected = 'N'
         and rq.acc_id = pacc_Id
         and rq.dept_id = pdept_id
         and rq.type_of_req = 'VACATION_LEAVE';
    rez boolean;
  begin
    rez := false;
    for x in c_get_pend_vac_leave loop
      rez := true;
    end loop;
    return rez;
  end;
  -- 
  function get_overlapped_days(p_st_date date, p_end_date date, p_dept_id number) return col_overlapped_days as
    od col_overlapped_days;
    currDate date;
    stDt date;
    
    D number;
    Mnth varchar2(30);
  begin
    od := col_overlapped_days();
    for x in (select * from requests rq where rq.resolved = 'D' and rq.dept_id  = p_dept_id and (trunc(rq.start_date) <= trunc(p_end_date) and trunc(rq.end_date) >= trunc(p_st_date))) loop
      currDate := x.start_date;
      loop
        exit when currDate > x.end_date;
          if (is_working_day(currDate)) then
            if(trunc(currDate) >= p_st_date and trunc(currDate) <= p_end_date) then
              D := to_number(extract(DAY from currDate));
              Mnth := to_char(to_date(to_number(extract(month from currDate)), 'MM'), 'MONTH');
              od.extend;
              od(od.last).day_overlapped := D;
              od(od.last).month_of_day := Mnth;
            end if;
          else 
            currDate := currDate + 1;
            continue;    
          end if;
        currDate := currDate + 1;    
      end loop;
    end loop;
    return od;
  end;
end AC_req_actions;
