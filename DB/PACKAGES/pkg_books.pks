
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
  pi_description in books.description%type,
  pi_cover in books.cover%type,
  pi_mime in books.MIME_TYPE%type,
  pi_file_name in books.FILE_NAME%type
);

procedure p_data_export;

procedure p_delete_book(
  pi_id in books.id%type
);
procedure p_restore_book(
  pi_id in books.id%type
);
end pkg_books;