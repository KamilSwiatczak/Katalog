create or replace package body pkg_books_genres
as
  gc_scope_prefix constant varchar2(31) := lower('pkg_books_genres') || '.';
function f_create_book_genre(
  pi_name        in         VARCHAR2
) return NUMBER 
is 
  v_scope logger_logs.scope%type := gc_scope_prefix || 'f_create_book_genre';
  v_params logger.tab_param;
  v_id NUMBER;
begin
  logger.append_param(v_params, 'p_name', pi_name);
  logger.log('START', v_scope, null, v_params);
  INSERT INTO BOOK_GENRES (name)
    VALUES (pi_name)
    RETURNING id INTO v_id;
  logger.log('END', v_scope);
  RETURN v_id;
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end f_create_book_genre;

procedure p_update_book_genre(
      pi_id    in NUMBER,
      pi_name  in VARCHAR2
    )IS
      v_scope logger_logs.scope%type := gc_scope_prefix || 'p_update_book_genre';
      v_params logger.tab_param;
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.append_param(v_params, 'pi_name', pi_name);
    logger.log('START', v_scope, null, v_params);
    UPDATE BOOK_GENRES
    SET name = pi_name
    WHERE id = pi_id;
    logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
  end p_update_book_genre;

procedure p_delete_book_genre(
  pi_id in NUMBER
)IS 
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_delete_book_genre';
  v_params logger.tab_param;
  v_number_of_books NUMBER;
begin
  logger.append_param(v_params, 'pi_id', pi_id);
  logger.log('START', v_scope, null, v_params);
  select count (*) into v_number_of_books from BOOKS 
  where GENRE_ID = pi_id;
  IF v_number_of_books = 0 THEN
      DELETE FROM BOOK_GENRES
      WHERE id = pi_id;
    ELSE
      RAISE egenreshasbooks;
    END IF;
  logger.log('END', v_scope);
exception
  when egenreshasbooks then     
    logger.log_error(
    'Gatunek ma książki.', v_scope, null, v_params
    );
    raise;
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_delete_book_genre;
  
end pkg_books_genres;
/