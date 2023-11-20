
create or replace package pkg_books
as



/** Opis działania procedury
* @param pi_parametr - opis_parametru
*/

procedure p_book_creation(
  pi_title in books.title%type,
  pi_author in books.author%type,
  pi_isbn in books.isbn%type,
  pi_year in books.year%type,
  pi_genre in books.genre_id%type,
  pi_location in books.location_id%type,
  pi_score in books.score%type,
  pi_description in books.description%type
--   pi_cover in books.cover%type
);

    

end pkg_books;

