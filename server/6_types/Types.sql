-- below we have the necessary types for the webapp to use and 
create or replace type overlap_day as object(
  day_overlapped number,
  month_of_day number
  
);

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

--
create type new_employee_type as object(
  acc_id number,
  emp_id number,
  f_name varchar2(80),
  l_name varchar2(80),
  email varchar2(120),
  dep_id number,
  tm_id number,
  hire_date date, 
  trial_period varchar2(1),
  user_name varchar2(20),
  user_role varchar2(60),
  crypted_pass varchar2(2000) -- we send the crypted pass in the db so we can send the encryption at  every logIn so we may only compare HashStrings 
);