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
  


-- Grid save
procedure p_manage_book_genre(
  pi_row_status CHAR,
  pio_id in out NUMBER,
  pi_name in VARCHAR2)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_manage_book_genre';
  v_params logger.tab_param;


begin
  logger.append_param(v_params, 'pi_row_status', pi_row_status);
  logger.append_param(v_params, 'pio_id', pio_id);
  logger.append_param(v_params, 'pi_name', pi_name);
  logger.log('START', v_scope, null, v_params);
      case pi_row_status
    when 'C' then
        pio_id := pkg_books_genres.f_create_book_genre(pi_name);
    when 'U' then
        pkg_books_genres.p_update_book_genre(pio_id, pi_name);
    when 'D' then
		    pkg_books_genres.p_delete_book_genre(pio_id);
    end case;

  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_manage_book_genre;

  
  
  -- Opis Procedury
  procedure p_delete_empty_genres
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_delete_empty_genres';
    v_params logger.tab_param;
    v_number_of_books NUMBER;
  begin
    logger.log('START', v_scope, null, v_params);
  
    for row in (select * from BOOK_GENRES)  loop
      logger.log(row.name, v_scope);
      select count (*) into v_number_of_books from BOOKS where GENRE_ID = row.id;
      logger.log('W rodzaju '|| row.name ||' jest '|| v_number_of_books|| ' książek.', v_scope);
      if v_number_of_books = 0 then 
        delete from BOOK_GENRES
         where ID = row.id;
      end if;
    end loop;
  
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
  end p_delete_empty_genres;
  
    

end pkg_books_genres;
/