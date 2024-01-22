
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
  pi_file_name in books.FILE_NAME%type,
  pi_publisher in BOOKS.PUBLISHER%type,
  pi_language in BOOKS.LANGUAGE%type
);

procedure p_data_export;

procedure p_delete_book(
  pi_id in books.id%type
);
procedure p_restore_book(
  pi_id in books.id%type
);

procedure p_openlibrary_api(
  pi_isbn in books.isbn%type
);
procedure p_openlibrary_api_insert(
    pi_isbn in books.isbn%type,
    po_year out books.year%type,
    po_title out books.title%type,
    po_author out books.author%type,
    po_publisher out books.publisher%type,
    po_language out books.language%type,
    po_cover out books.cover%type,
    po_mime_type out books.mime_type%type
);
end pkg_books;