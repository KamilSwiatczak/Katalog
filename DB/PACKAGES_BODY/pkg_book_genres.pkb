create or replace package body pkg_book_genres
as
  gc_scope_prefix constant varchar2(31) := lower('pkg_book_genres') || '.';




function f_create_book_genre(
    pi_name in book_genres.name%type
  ) return book_genres.id%type 
  is 
    v_scope logger_logs.scope%type := gc_scope_prefix || 'f_create_book_genre';
    v_params logger.tab_param;
    v_id books.id%type;
  begin
    logger.append_param(v_params, 'pi_name', pi_name);
    logger.log('START', v_scope, null, v_params);

    if not f_check_book_genres_exists(pi_name) then
      INSERT INTO BOOK_GENRES (name)
        VALUES (pi_name)
        RETURNING id INTO v_id;
      RETURN v_id;
    else
      raise_application_error(-20001, 'Gatunek o nazwie "' || pi_name || '" już istnieje.');
    end if;
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end f_create_book_genre;




function f_check_book_genres_exists(
    pi_name in book_genres.name%type
  ) return BOOLEAN
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'f_check_book_genres_exists';
    v_params logger.tab_param;
    v_genre_count number;
  begin
    logger.append_param(v_params, 'pi_name', pi_name);
    logger.log('START', v_scope, null, v_params);

    select count(*) into v_genre_count
    from BOOK_GENRES
    where name = pi_name;

    logger.log('END', v_scope);
    return v_genre_count > 0;
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end f_check_book_genres_exists;

  


procedure p_update_book_genre(
        pi_id    in book_genres.id%type,
        pi_name  in book_genres.name%type
      )IS
        v_scope logger_logs.scope%type := gc_scope_prefix || 'p_update_book_genre';
        v_params logger.tab_param;
        
    begin
      logger.append_param(v_params, 'pi_id', pi_id);
      logger.append_param(v_params, 'pi_name', pi_name);
      logger.log('START', v_scope, null, v_params);

      if not f_check_book_genres_exists(pi_name) then
        UPDATE BOOK_GENRES
        SET name = pi_name
        WHERE id = pi_id;
        else
          raise_application_error(-20001, 'Gatunek o nazwie "' || pi_name || '" już istnieje.');
      end if;
      logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_update_book_genre;

procedure p_delete_book_genre(
    pi_id in book_genres.id%type
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
  



procedure p_manage_book_genre(
    pi_row_status CHAR,
    pio_id in out book_genres.id%type,
    pi_name in book_genres.name%type)
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
        if pi_name is not null then
            pio_id := pkg_book_genres.f_create_book_genre(pi_name);
          else raise_application_error(-20001, 'Gatunek musi mieć nazwę.');
        end if;
      when 'U' then
        if pi_name is not null then
            pkg_book_genres.p_update_book_genre(pio_id, pi_name);
          else raise_application_error(-20001, 'Gatunek musi mieć nazwę.');
        end if;
      when 'D' then
          pkg_book_genres.p_delete_book_genre(pio_id);
      end case;

    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_manage_book_genre;



function f_check_genre_has_books(
pi_id in book_genres.id%type) return BOOLEAN
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'f_check_genre_has_books';
  v_params logger.tab_param;
  v_number_of_books number;
begin
  logger.append_param(v_params, 'pi_id', pi_id);
  logger.log('START', v_scope, null, v_params);

  select count (*) into v_number_of_books from BOOKS where GENRE_ID = pi_id;

  logger.log('END', v_scope);
  return v_number_of_books > 0;
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end f_check_genre_has_books;

  


  -- usuwanie wszystkich pustych gatunków stare
procedure p_delete_empty_genres
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_delete_empty_genres';
    v_params logger.tab_param;
    v_number_of_books NUMBER;
  begin
    logger.log('START', v_scope, null, v_params);
  
    for row in (select * from BOOK_GENRES)  loop
      if not f_check_genre_has_books(row.id) then 
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
    pi_source_id IN book_genres.id%type,
    pi_target_id IN book_genres.id%type
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