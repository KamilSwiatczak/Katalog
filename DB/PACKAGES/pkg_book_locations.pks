create or replace package pkg_book_locations
as


procedure p_create_edit_location(
  pi_id in locations.id%type,
  pi_name in locations.name%type
);

procedure p_remove_location(
  pi_id in locations.id%type
); 

end pkg_book_locations;
/