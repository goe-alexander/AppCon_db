-- below we have the necessary types for the webapp to use and 
create type emp_details_type as object(
  acc_id number,
  emp_id number,
  f_name varchar2(80),
  l_name varchar2(80),
  dep_id number,
  tm_id number,
  email varchar2(80),
  hire_date date
);

create public synonym emp_details_type for emp_details_type ;

declare 

  a number;

begin
  
  a := remaining_days.get_default_remaining_days(0, 2);
  dbms_output.put_line(a);
end;
