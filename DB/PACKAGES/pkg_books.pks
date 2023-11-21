
create or replace package pkg_books
as


procedure p_book_create_update(
  pi_id in books.id%type,
  pi_title in books.title%type,
  pi_author in books.author%type,
  pi_isbn in books.isbn%type,
  pi_year in books.year%type,
  pi_genre_id in books.genre_id%type,
  pi_location_id in books.location_id%type,
  pi_score in books.score%type,
  pi_description in books.description%type
);

procedure p_data_export;

end pkg_books;

