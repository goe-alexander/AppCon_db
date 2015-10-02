create or replace package EMP_details as 
  procedure get_emp_details(p_acc_name in varchar2, p_emp_out out emp_details_type);
end EMP_details;

create or replace package body EMP_details as
  procedure get_emp_details(p_acc_name in varchar2, p_emp_out out emp_details_type) as
    cursor cget_emp_det is
      select nvl(au.id, '') id,
             nvl(au.emp_id, '') emp_id,
             nvl(emp.f_name, '') f_name,
             nvl(emp.l_name,'') l_name,
             nvl(emp.dep_id,'') dep_id,
             nvl(emp.tm_id,'') tm_id,
             nvl(emp.email,'') email,
             nvl(emp.hire_date, '') hire_date
        from app_users au
        join employees emp
          on au.emp_id = emp.emp_id
       where upper(au.code) = upper(p_acc_name)
         and rownum = 1;
    ced cget_emp_det%rowtype;     
  begin
    open cget_emp_det;
    fetch cget_emp_det into ced;
    if cget_emp_det%found then
      p_emp_out := emp_details_type(ced.id, ced.emp_id, ced.f_name, ced.l_name, ced.dep_id, ced.tm_id, ced.email, ced.hire_date);
    end if;
    close cget_emp_det;
  end;
end  EMP_details;
