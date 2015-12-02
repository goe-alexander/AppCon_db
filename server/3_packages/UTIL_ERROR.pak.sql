-- package for raising errorsdynamic errors 
create or replace package UTIL_ERROR as 
  /*Gets the description of a particular error code. */
  function get_err_msg(err_code varchar2) return varchar2;
  /*Used for small nonspecific errors that do not reuire insertion i SL_ERRORS*/
  procedure raise_generic_err(err_Msg varchar2);
  
end UTIL_ERROR;
