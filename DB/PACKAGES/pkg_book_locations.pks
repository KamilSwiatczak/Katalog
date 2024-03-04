create or replace package pkg_book_locations
as


procedure p_create_edit_location(
  pi_id in locations.id%type,
  pi_name in locations.name%type
);

procedure p_remove_location(
  pi_id in locations.id%type
); 

function f_check_if_full RETURN APEX_T_NUMBER;

end pkg_book_locations;
/