select * from requests;
select * from request_types;
select * from status_types for update


create or replace package REMAINING_DAYS as
  -- admin procedure for registering new accounts.
  function get_remaining_vac_days(pacc_id number, pdept_id number, pnow_interval number) return number;
end REMAINING_DAYS;
create or replace package body REMAINING_DAYS as

-- all private parameters start with pp,  they will be all initialized by the private procedure init_pp()
  pp_emp_id number;
  pp_trial_period varchar2(1) := 'N';
  pp_hired_this_year boolean := false;
  pp_total_leave_days days_per_year.max_no_days%type;
  pp_dept_code varchar2(60);

  procedure init_pp(pacc_id number, pdept_id number) is
    cursor c_get_emp is
      select ap.emp_id
        from app_users ap
       where ap.id = pacc_id;
    cge c_get_emp%rowtype;
    init_err varchar2(500);
  begin
    open c_get_emp;
    fetch c_get_emp into cge;
    if c_get_emp%found then
      pp_emp_id := cge.emp_id;
      begin
        select dp.max_no_days into pp_total_leave_days from days_per_year dp where dp.req_code = 'VACATION_LEAVE';
        select emp.trial_period into  pp_trial_period  from employees emp where emp.emp_id = (select ap.emp_id from app_users ap where ap.id = pacc_id);
        select dt.code into pp_dept_code from departments dt where dt.dep_id = pdept_id;
        for x in (select 1 from employees emp where emp.emp_id = pp_emp_id and extract(YEAR from emp.hire_date) = extract(year from sysdate) and rownum = 1) loop
          pp_hired_this_year := true;
        end loop;
      exception
        when no_data_found then
          pp_trial_period := 'X';
          raise_application_error(-20100, 'Unable to determine if in trial_period');
      end;
    else
      -- the employee was not found
      pp_emp_id := null;
      raise_application_error(-20155, 'Unable to determine employee id');
    end if;
    close c_get_emp;
  exception
    when others then
      init_err := substr(sqlerrm, 1, 500);
      raise_application_error(-20156, init_err);
  end;

  function days_for_emp_hired_recently(pemp_id number) return number as
    mb number;
    errm varchar2(500);
    calc_days number;
  begin
    begin
      select months_between((add_months(trunc(sysdate, 'YEAR'), 12) - 1),
                            (select hire_date
                               from employees e
                              where e.emp_id = pemp_id))
        into mb
        from dual;
    exception
      when no_data_found then
        errm := substr(sqlerrm, 1, 500);
        raise_application_error( -20150, errm);
    end;
    calc_days := round((mb * 2), 0 );
    return calc_days;
  exception
    when others then
      errm := substr(sqlerrm, 1, 500);
      raise_application_error( -20100, errm);
  end;



  function get_remaining_vac_days(pacc_id number, pdept_id number, pnow_interval number) return number as
    cursor c_get_taken_days is
      select rq.total_no_of_days
        from requests rq
       where acc_id = pacc_id
         and rq.dept_id = pdept_id
         and rq.status = 'RESOLVED'
         and extract(YEAR FROM rq.start_date) = extract(YEAR from sysdate)
         and rq.resolved = 'D'
         and rq.type_of_req = 'VACATION_LEAVE';

    total_days_taken number := 0;
    remaining_result number;
    errm varchar2(580);
  begin
  -- we initialize the package variables
    init_pp(pacc_id, pdept_id );
  -- we get what was already taken
    for x  in c_get_taken_days  loop
      total_days_taken := total_days_taken + x.total_no_of_days;
    end loop;
    if (pp_trial_period = 'N' and  pp_hired_this_year = false) then
       -- standard number of days apply
       remaining_result :=  pp_total_leave_days - (total_days_taken + pnow_interval);
    elsif(pp_trial_period = 'N' and pp_hired_this_year = true) then
      -- we calculate the ammount of legal leaves the emo has and extract from that what he has already taken (from approved requests)
      remaining_result := days_for_emp_hired_recently(pp_emp_id);
      remaining_result := remaining_result - (total_days_taken + pnow_interval);
    elsif (pp_trial_period = 'D') then
      -- assuming standard contract is 3 months then we have
      remaining_result := 6 - (total_days_taken + pnow_interval);
    end if;
    return remaining_result;
  exception
    when others then
      errm := substr(sqlerrm,1,500);
      raise_application_error(-20150, errm) ;
  end;

  function get_max_sick_days_year return number as
  begin
    null;
  end;
end REMAINING_DAYS;
