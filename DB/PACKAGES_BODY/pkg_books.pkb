
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
    pi_file_name in books.FILE_NAME%type
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
  logger.log('START', v_scope, null, v_params);

  if pi_id is null then
    INSERT INTO BOOKS (title, author, isbn, year, genre_id, location_id, score, description, cover, MIME_TYPE, FILE_NAME)
    VALUES (pi_title, pi_author, pi_isbn, pi_year, pi_genre_id, pi_location_id, pi_score, pi_description, pi_cover, pi_mime, pi_file_name);
    select id into v_id from books where  isbn = pi_isbn and title = pi_title;
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

PROCEDURE p_data_export as
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
      DELETE FROM books 
      WHERE ID=pi_id;
      else
      update BOOKS
      set DELETED ='Y'
      where id = pi_id;
      pkg_history.p_history_log(pi_action => 'DELETE', pi_book_id => pi_id);
    end if;
    
    logger.log('Książka usunięta.', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
  end p_delete_book;
  
    

end pkg_books;