create or replace package pkg_book_genres
as
-- Declare the exception
    egenreshasbooks EXCEPTION;

-- Define a function for Create
    FUNCTION f_create_book_genre(
    pi_name in books.title%type
    ) RETURN books.id%type;
-- Define procedures for Update and Delete
    PROCEDURE p_update_book_genre(
        pi_id in books.id%type,
        pi_name in books.title%type
    );

    PROCEDURE p_delete_book_genre(
        pi_id in books.id%type
    );

--grid save

procedure p_manage_book_genre(
  pi_row_status CHAR,
  pio_id in out books.id%type,
  pi_name in books.title%type
);

procedure p_delete_empty_genres;

procedure p_remove_empty_genres;
    
procedure p_eradicate_empty_genres;

procedure p_merge_book_genres(
    pi_source_id in books.id%type,
    pi_target_id in books.id%type
);

end pkg_book_genres;
/