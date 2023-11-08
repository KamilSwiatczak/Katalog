create or replace package pkg_books_genres
as
-- Declare the exception
    egenreshasbooks EXCEPTION;
-- Define a function for Create
    FUNCTION f_create_book_genre(
    pi_name in VARCHAR2
    ) RETURN NUMBER;
-- Define procedures for Update and Delete
    PROCEDURE p_update_book_genre(
        pi_id in NUMBER,
        pi_name in VARCHAR2
    );
    PROCEDURE p_delete_book_genre(
        pi_id in NUMBER
    );

--grid save

procedure p_manage_book_genre(
  pi_row_status CHAR,
  pio_id in out NUMBER,
  pi_name in VARCHAR2
);




procedure p_delete_empty_genres;

    
    
end pkg_books_genres;
/