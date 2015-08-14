select * from user_tables;
select * from role_types;
select * from employees;
select * from app_users;
select * from user_credentials;
select * from departments for update;
select * from requests;
insert into employees(emp_id, f_name, l_name, email, hire_date, tm_id, dep_id) values (4, 'MARIUS', 'SEF', 'Marius.sef@gmail.com', sysdate, null, 7);
insert into user_credentials(user_nm, pass_word) values('MARIUS.SEF', 'Project#man');
insert into user_credentials(user_nm, pass_word) values('ADMIN', 'ADMIN');
insert into user_credentials(user_nm, pass_word) values('GOE.ALEX', 'Rom012345');
insert into user_credentials(user_nm, pass_word) values('GOE.USER', 'rom#012345');

insert into app_users(id, code, emp_id, active) values(3, 'MARIUS.SEF', 4, 'D'); 
select * from user_tables;
select * from user_atributions;
select * from role_types;
select * from role_types;
select * from user_credentials;
truncate table user_credentials;
insert into user_atributions(user_id, role_id) values(0,1);
insert into user_atributions(user_id, role_id) values(1,3);
insert into user_atributions(user_id, role_id) values(2,5);
insert into user_atributions(user_id, role_id) values(3,2);


select * from 

select rt.role_code from user_atributions ua
											join role_types rt on ua.role_id = rt.role_id
											where ua.user_id = (select au.id from app_users au where au.code = upper('GOE.ALEX'))
    
Select 1 from user_credentials uc where upper(uc.user_nm) = 'admin' and uc.pass_word = ?
