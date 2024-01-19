
create or replace package body pkg_books
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_books') || '.';




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
  )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_book_create_update';
    v_params logger.tab_param;
    v_id books.id%type;
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.append_param(v_params, 'pi_title', pi_title);
    logger.append_param(v_params, 'pi_author', pi_author);
    logger.append_param(v_params, 'pi_isbn', pi_isbn);
    logger.append_param(v_params, 'pi_year', pi_year);
    logger.append_param(v_params, 'pi_genre_id', pi_genre_id);
    logger.append_param(v_params, 'pi_location_id', pi_location_id);
    logger.append_param(v_params, 'pi_score', pi_score);
    logger.append_param(v_params, 'pi_description', pi_description);
    logger.append_param(v_params, 'pi_mime', pi_mime);
    logger.append_param(v_params, 'pi_file_name', pi_file_name);
    logger.append_param(v_params, 'pi_publisher', pi_publisher);
    logger.append_param(v_params, 'pi_language', pi_language);
    logger.log('START', v_scope, null, v_params);

    if pi_id is null then
      INSERT INTO BOOKS (title, author, isbn, year, genre_id, location_id, score, description, cover, MIME_TYPE, FILE_NAME, PUBLISHER, LANGUAGE)
      VALUES (pi_title, pi_author, pi_isbn, pi_year, pi_genre_id, pi_location_id, pi_score, pi_description, pi_cover, pi_mime, pi_file_name, pi_publisher, pi_language)
      returning id into v_id;
      pkg_history.p_history_log(pi_action => 'NEW', pi_book_id => v_id);
      logger.log('Książka '||pi_title||' została dodana.', v_scope);
    else update books
          set title=pi_title,
              author=pi_author,
              isbn=pi_isbn,
              year=pi_year,
              genre_id=pi_genre_id,
              location_id=pi_location_id,
              score=pi_score,
              description=pi_description,
              PUBLISHER=pi_publisher,
              LANGUAGE=pi_language,
              cover=nvl(pi_cover, cover),
              mime_type=nvl(pi_mime, mime_type),
              file_name=nvl(pi_file_name, file_name)
          where ID = pi_id;
          pkg_history.p_history_log(pi_action => 'UPDATE', pi_book_id => pi_id);
          logger.log('Książka '||pi_title||' została edytowana.', v_scope);
    end if;
  logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_book_create_update;




PROCEDURE p_data_export 
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_data_export';
    v_params logger.tab_param;
    l_context apex_exec.t_context; 
    l_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    l_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 
        'select b.title, b.author, b.isbn, b.year, g.name as Genre, l.name as Location, b.score, b.description 
        from books b
        left join book_genres g 
        on b.genre_id = g.id
        left join locations l 
        on b.location_id = l.id' 
        );

    l_export := apex_data_export.export (
                        p_context   => l_context,
                        p_format    => apex_data_export.c_format_xlsx,
                        p_file_name => 'Raport książek');

    apex_exec.close( l_context );

    apex_data_export.download( p_export => l_export );
    logger.log('Eksportowano raport', v_scope);
  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( l_context );
        raise;
END p_data_export;    
  
  
  

procedure p_delete_book(
    pi_id in books.id%type)
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_delete_book';
    v_params logger.tab_param;
    v_row_count NUMBER;
  
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.log('START', v_scope, null, v_params);

    SELECT COUNT(*)
    INTO v_row_count
    FROM history
    WHERE book_id = pi_id;
    
    if v_row_count <= 1 THEN 
      DELETE FROM history
      WHERE book_id=pi_id;
      DELETE FROM books 
      WHERE ID=pi_id;
    else
      update BOOKS
      set DELETED ='Y'
      where ID = pi_id;

      pkg_history.p_history_log(pi_action => 'DELETE', pi_book_id => pi_id);
    end if;
    
    logger.log('Książka usunięta.', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_delete_book;
  



procedure p_restore_book(
    pi_id in books.id%type)
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_book';
    v_params logger.tab_param;
    v_deleted_count NUMBER;
  
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.log('START', v_scope, null, v_params);
    select count(*)
    into v_deleted_count
    from BOOKS
    where id = pi_id AND DELETED = 'Y';
  
    if v_deleted_count = 1 THEN
      update BOOKS
      set DELETED ='N'
      where id = pi_id;
  
      pkg_history.p_history_log(pi_action => 'RESTORE', pi_book_id => pi_id);
      logger.log('Książka przywrócona', v_scope);
    else 
      RAISE_APPLICATION_ERROR(-20006, 'Książka nie była usunięta.');
    end if;
  
    logger.log('END', v_scope);
    
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_book;





procedure p_openlibrary_api(
    pi_isbn in books.isbn%type)
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_openlibrary_api';
    v_params logger.tab_param;
    v_url VARCHAR2(4000);
    v_cover_url VARCHAR2(4000);
    v_response CLOB;
    v_cover BLOB;
    j apex_json.t_values;
    v_id varchar2(200);
    v_members apex_t_varchar2;
    v_year varchar2(200);
    v_publisher varchar2(200);
    v_title varchar2(200);
    v_author varchar2(200);
    v_lang varchar2(200);
  begin
    logger.append_param(v_params, 'pi_isbn', pi_isbn);
    logger.log('START', v_scope, null, v_params);
    v_url := 'https://openlibrary.org/api/volumes/brief/isbn/'||TO_CHAR(pi_isbn)||'.json';
    v_cover_url := 'https://covers.openlibrary.org/b/isbn/'||TO_CHAR(pi_isbn)||'-S.jpg'; 
    v_response := APEX_WEB_SERVICE.MAKE_REST_REQUEST(
        p_url => v_url,
        p_http_method => 'GET'
    );
    v_cover := APEX_WEB_SERVICE.MAKE_REST_REQUEST_B(
        p_url => v_cover_url,
        p_http_method => 'GET'
    );
    apex_json.parse(j, v_response);
    
    v_members := apex_json.GET_MEMBERS (
        p_values => j,
        p_path => 'records'
    );
    
    v_id := v_members(1);
    
    v_year := APEX_JSON.GET_VARCHAR2 (
        p_path => 'records.%0.data.publish_date',
        p0 => v_id,
        p_values => j
    );
    v_title := APEX_JSON.GET_VARCHAR2 (
      p_path => 'records.%0.data.title',
      p0 => v_id,
      p_values => j
    );
    v_publisher := APEX_JSON.GET_VARCHAR2 (
        p_path => 'records.%0.data.publishers[1].name',
        p0 => v_id,
        p_values => j
    );
    v_author := APEX_JSON.GET_VARCHAR2 (
        p_path => 'records.%0.data.authors[1].name',
        p0 => v_id,
        p_values => j
    );
    v_lang := APEX_JSON.GET_VARCHAR2 (
      p_path => 'records.%0.details.details.languages[1].key',
      p0 => v_id,
      p_values => j
    );
    IF v_year IS NOT NULL THEN
      update books
        set YEAR=SUBSTR(v_year,-4)
      where ISBN=pi_isbn;
    END IF;
    IF v_title IS NOT NULL THEN
      update books
        set TITLE=v_title
      where ISBN=pi_isbn;
    END IF;
    IF v_author IS NOT NULL THEN
      update books
        set AUTHOR=v_author
      where ISBN=pi_isbn;
    END IF;
    IF v_publisher IS NOT NULL THEN
      update books
        set PUBLISHER=v_publisher
      where ISBN=pi_isbn;
    END IF;
    IF v_lang = '/languages/pol' then
      update books
        set LANGUAGE='polski'
      where ISBN=pi_isbn;
      elsif v_lang = '/languages/eng' then
        update books
        set LANGUAGE='angielski'
      where ISBN=pi_isbn;
      else update books
        set LANGUAGE=v_lang
      where ISBN=pi_isbn;
    END IF;
    IF v_cover IS NOT NULL THEN
      update books
        set COVER=v_cover, MIME_TYPE='image/jpeg'
      where ISBN=pi_isbn;
    END IF;
  logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;

end p_openlibrary_api;


  
    

end pkg_books;