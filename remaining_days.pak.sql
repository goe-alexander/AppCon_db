select * from requests;
select * from request_types;
select * from status_types for update


create or replace package REMAINING_DAYS as 
  -- admin procedure for registering new accounts.
  function get_remaining_vac_days(pacc_id number, pdept_id number);
  function get_max_sick_days_year();
end REMAINING_DAYS;


create or replace package body REMAINING_DAYS as
  function get_remaining_vac_days(pacc_id number, pdept_id number) return number as
    cursor c_get_remaining_days is
      select rq.total_no_of_days
        from requests rq
       where acc_id = pacc_id
         and rq.dept_id = pdept_id
         and rq.status = 'RESOLVED'
         and extract(YEAR FROM rq.start_date) = extract(YEAR from sysdate)
         and rq.resolved = 'D';
    total_days_taken number;   
    errm varchar2(500);  
  begin
    total_days_taken := 0;
    for x  in (c_get_remaining_days)  loop 
      total_days_taken := total_days_taken + x.total_no_of_days;
    end loop;
    
    return total_days_taken;
  exception 
    when others then 
      raise ;
  end;

end REMAINING_DAYS;