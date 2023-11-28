create or replace package pkg_book_lending
as
  

procedure p_create_book_lending(
  pi_book_id in book_lending.book_id%type,
  pi_person in book_lending.person%type,
  pi_date in book_lending.start_date%type
);

procedure p_book_returning(
  pi_book_id in book_lending.book_id%type,
  pi_date in book_lending.end_date%type
);

end pkg_book_lending;