create or replace package body pkg_book_genres
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

  
  
  -- usuwanie wszystkich pustych gatunków stare
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
  
    
    
  -- usuwanie wszystkich pustych gatunków nowe
    procedure p_remove_empty_genres
    as
      v_scope logger_logs.scope%type := gc_scope_prefix || 'p_remove_empty_genres';
      v_params logger.tab_param;
    begin
      logger.log('START', v_scope, null, v_params);
    
      DELETE FROM BOOK_GENRES 
      WHERE ID NOT IN (
        select distinct BOOKS.GENRE_ID 
        from BOOKS
        );
    
      logger.log('END', v_scope);
    exception
      when others then
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
    end p_remove_empty_genres;
    
        --usuwanie wszystkich pustych gatunków inne
  procedure p_eradicate_empty_genres
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_delete_empty_genres';
    v_params logger.tab_param;
  begin
    logger.log('START', v_scope, null, v_params);
  
    for row in (
      select distinct BOOK_GENRES.ID
      from BOOKS
      right join BOOK_GENRES on BOOKS.GENRE_ID = BOOK_GENRES.ID
      where books.id is null
      )  
      loop
         delete from BOOK_GENRES
         where ID = row.id;
      
    end loop;
  
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
  end p_eradicate_empty_genres;

  
  
  -- Merging two book genres
  procedure p_merge_book_genres(
    pi_source_id IN NUMBER,
    pi_target_id IN NUMBER
    )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_merge_book_genres';
    v_params logger.tab_param;
  
  begin
    logger.append_param(v_params, 'pi_source_id', pi_source_id);
    logger.append_param(v_params, 'pi_target_id', pi_target_id);
    logger.log('START', v_scope, null, v_params);
  
    update books
    set GENRE_ID = pi_target_id
    where GENRE_ID = pi_source_id;
    delete from BOOK_GENRES WHERE ID=pi_source_id;
  
    logger.log('Gatunki połączone', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
  end p_merge_book_genres;
  
    

end pkg_book_genres;
/

