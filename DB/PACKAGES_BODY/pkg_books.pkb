
create or replace package body pkg_books
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_books') || '.';



-- Opis Procedury
procedure p_book_creation(
    pi_title in books.title%type,
    pi_author in books.author%type,
    pi_isbn in books.isbn%type,
    pi_year in books.year%type,
    pi_genre in books.genre_id%type,
    pi_location in books.location_id%type,
    pi_score in books.score%type,
    pi_description in books.description%type
    -- pi_cover in books.cover%type
)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_book_creation';
  v_params logger.tab_param;

begin
  logger.append_param(v_params, 'pi_title', pi_title);
  logger.append_param(v_params, 'pi_author', pi_author);
  logger.append_param(v_params, 'pi_isbn', pi_isbn);
  logger.append_param(v_params, 'pi_year', pi_year);
  logger.append_param(v_params, 'pi_genre', pi_genre);
  logger.append_param(v_params, 'pi_location', pi_location);
  logger.append_param(v_params, 'pi_score', pi_score);
  logger.append_param(v_params, 'pi_description', pi_description);
--   logger.append_param(v_params, 'pi_cover', pi_cover); nie da się
  
  logger.log('START', v_scope, null, v_params);

  INSERT INTO BOOKS (title, author, isbn, year, genre_id, location_id, score, description)
  VALUES (pi_title, pi_author, pi_isbn, pi_year, pi_genre, pi_location, pi_score, pi_description);

  logger.log('Książka '||pi_title||' dodana.', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_book_creation;

    

end pkg_books;

