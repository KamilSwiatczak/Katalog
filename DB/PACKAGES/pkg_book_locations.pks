create or replace package pkg_book_locations
as


/** Opis działania procedury
* @param pi_parametr - opis_parametru
*/

procedure p_create_edit_location(
  pi_id in NUMBER,
  pi_name in VARCHAR2
);

procedure p_remove_location(
  pi_id in NUMBER
); 

end pkg_book_locations;
/