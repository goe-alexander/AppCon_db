create or replace package EMP_details as 
  procedure get_emp_details(p_acc_name in varchar2, p_emp_out out emp_details_type);
  -- we create another procedure to check the users role 
  procedure get_users_role(papp_user_code varchar2, out_usr_role out varchar2);
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
  
  
  --This procedure will return the users role in thlogin backing bean 
  -- immediately after validating login credentials
  
  procedure get_users_role(papp_user_code varchar2, out_usr_role out varchar2) as
    cursor c_get_usr_role is
      select rt.role_code from user_atributions ua
											join role_types rt on ua.role_id = rt.role_id 
												where ua.user_id = (select au.id from app_users au where au.code = upper(papp_user_code));
                        
    cg_ur c_get_usr_role%rowtype;
    errm varchar2(250);
  begin
    open c_get_usr_role;
    fetch c_get_usr_role into cg_ur;
    if c_get_usr_role%found then 
      out_usr_role :=  cg_ur.role_code;
    else
      out_usr_role := 'No role found for user';
    end if;
  exception 
    when others then 
      errm := substr(sqlerrm, 1, 250);  
      out_usr_role := 'Issue in determining role: ' || errm; 
  end;
end  EMP_details;
