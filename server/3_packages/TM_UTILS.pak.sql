

create or replace package TM_UTILS as
  Type CONFLICTED_REQUESTS is VARRAY(20) of number(8);
  --- List of procedures
  procedure validate_request(pid number, pout_msg varchar2);
  function getCONFLICTED_REQUESTS(pid_dept number) return CONFLICTED_REQUESTS;
  procedure Smart_Validation(pid_dept number);
  -- passing attributions to another TM
  procedure Pass_Attributions(pempl_id number, ptm_target varchar2);
end TM_UTILS;


create or replace package body TM_UTILS as 
  procedure validate_request(pid number, pout_msg varchar2) as 
  
  begin
    null;
  end;
  
  function getCONFLICTED_REQUESTS(pid_dept number) return CONFLICTED_REQUESTS as
  
  begin
    null;
  end;
  
  procedure Smart_Validation(pid_dept number) as
  
  begin
    null;
  end;
  
  -- passing attributions to another TM 
  procedure Pass_Attributions(pempl_id number, ptm_target varchar2) as
  
  begin
    null;
  end;
end TM_UTILS;