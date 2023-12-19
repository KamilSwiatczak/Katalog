create or replace package body pkg_backups
as
  gc_scope_prefix constant varchar2(31) := lower('pkg_backups') || '.';


PROCEDURE p_genres_export 
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_genres_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select * from book_genres');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'genres/genres_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content, mime_type)
    values (v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano book_lending', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( v_context );
        raise;
END p_genres_export;  




PROCEDURE p_actions_export 
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_actions_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select * from actions');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'actions/actions_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content, mime_type)
    values (v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano actions', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( v_context );
        raise;
END p_actions_export;  




PROCEDURE p_lending_export 
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_lending_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select * from book_lending');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'lending/lending_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content, mime_type)
    values (v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano book_lending', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( v_context );
        raise;
END p_lending_export;




PROCEDURE p_location_export as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_location_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select * from locations');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'locations/location_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content, mime_type)
    values (v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano locations', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( v_context );
        raise;
END p_location_export;    




PROCEDURE p_books_export as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_books_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
    -- v_column apex_data_export.t_columns;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select * from books');
    -- apex_data_export.ADD_COLUMN(
    --   p_columns => v_column,             
    --   p_name => 'ID'
    -- );
    -- apex_data_export.ADD_COLUMN(
    --   p_columns => v_column,
    --   p_name => 'TITLE'
    -- );
    -- apex_data_export.ADD_COLUMN(
    --   p_columns => v_column,
    --   p_name => 'AUTHOR'
    -- );
    -- apex_data_export.ADD_COLUMN(
    --   p_columns => v_column,
    --   p_name => 'ISBN'
    -- );

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'books/books_backup'
                    -- ,
                    -- p_columns   => v_column
                    );

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content, mime_type)
    values (v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano books', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( v_context );
        raise;
END p_books_export;




PROCEDURE p_backups_export as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_backups_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select * from backups');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'backups/backups_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content, mime_type)
    values (v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano backups', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( v_context );
        raise;
END p_backups_export;




PROCEDURE p_history_export as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_history_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select * from history');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'history/history_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content, mime_type)
    values (v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano history', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( v_context );
        raise;
END p_history_export;




procedure p_zip_backup
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_zip_backup';
    v_params logger.tab_param;
    v_zip_file blob;

  begin
    logger.log('START', v_scope, null, v_params);
    pkg_backups.p_books_export;
    pkg_backups.p_location_export;
    pkg_backups.p_genres_export;
    pkg_backups.p_lending_export;
    pkg_backups.p_history_export;
    pkg_backups.p_actions_export;
    for i in (select file_name, file_content
                  from MY_TEMP_FILES)
      loop
          apex_zip.add_file (
              p_zipped_blob => v_zip_file,
              p_file_name   => 'tables/'||i.file_name,
              p_content     => i.file_content);
      end loop;
    for c in (select id, title, file_name, cover
            from BOOKS
            where cover is not null)
      loop 
          apex_zip.add_file (
              p_zipped_blob => v_zip_file,
              p_file_name   => 'covers/'||c.id||'_'||c.title||SUBSTR(c.file_name, INSTR(c.file_name, '.', -1)),
              p_content     => c.cover);
      end loop;            
    apex_zip.finish (
          p_zipped_blob => v_zip_file);
    insert into backups (user_name, time, backup, mime_type, file_name)
    values (apex_custom_auth.get_username, LOCALTIMESTAMP, v_zip_file, 'application/zip', 'backup_'||LOCALTIMESTAMP||'.zip');
    delete from MY_TEMP_FILES;
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_zip_backup;


procedure p_backup_restore(
  pi_zip_file in blob)
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_backup_restore';
    v_params logger.tab_param;
    v_unzipped_file blob;
    v_files apex_zip.t_files;
  begin
    logger.append_param(v_params, 'pi_zip_file', length(pi_zip_file));
    logger.log('START', v_scope, null, v_params);

    v_files := apex_zip.get_files (
              p_zipped_blob => pi_zip_file);
  for i in 1 .. v_files.count 
        loop
          v_unzipped_file := apex_zip.get_file_content (
              p_zipped_blob => pi_zip_file,
              p_file_name   => v_files(i));
          insert into MY_TEMP_FILES (file_name, file_content)
          values (v_files(i), v_unzipped_file);
        end loop;
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_backup_restore;



procedure p_RESTORE_FROM_EXISTING_BACKUP(
  pi_backup_id backups.id%type)
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_RESTORE_FROM_EXISTING_BACKUP';
    v_params logger.tab_param;
    v_file_content blob;
  begin
    logger.append_param(v_params, 'pi_backup_id', pi_backup_id);
    logger.log('START', v_scope, null, v_params);

    select backup into v_file_content from backups
    where id = pi_backup_id;

    p_backup_restore(v_file_content);

    p_parse_to_collection;

    delete from BOOK_LENDING;
    delete from HISTORY;
    delete from BOOKS;
    delete from LOCATIONS;
    delete from BOOK_GENRES;
    delete from ACTIONS;

    
    p_restore_locations;
    p_restore_genres;
    p_restore_actions;
    p_restore_books;
    p_restore_lending;
    p_restore_history;
    
    delete from MY_TEMP_FILES;

    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'LOCATIONS_BACKUP');
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'GENRES_BACKUP');
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'ACTIONS_BACKUP');
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'BOOKS_BACKUP');
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'LENDING_BACKUP');
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'HISTORY_BACKUP');
    
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_RESTORE_FROM_EXISTING_BACKUP;


procedure p_parse_to_collection
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_parse_to_collection';
    v_params logger.tab_param;
    v_table_name varchar2(30); 
  begin
    logger.log('START', v_scope, null, v_params);
    
    for i in (
    select file_content, file_name
    from MY_TEMP_FILES where file_name like 'tables/%.xlsx')
    loop
    v_table_name := substr(i.file_name,instr(i.file_name,'/')+1,instr(i.file_name,'/',1,2)-instr(i.file_name,'/')-1)||'_backup';
    APEX_COLLECTION.CREATE_OR_TRUNCATE_COLLECTION(v_table_name);
    for c in (select * from table (apex_data_parser.parse(
                    p_content => i.file_content,
                    p_file_type => APEX_DATA_PARSER.c_file_type_xlsx,
                    p_skip_rows => 1
                    )))
        loop
          APEX_COLLECTION.ADD_MEMBER(
        p_collection_name => v_table_name,
          p_c001 => c.col001,
          p_c002 => c.col002,
          p_c003 => c.col003,
          p_c004 => c.col004,
          p_c005 => c.col005,
          p_c006 => c.col006,
          p_c007 => c.col007,
          p_c008 => c.col008,
          p_c009 => c.col009,
          p_c010 => c.col010,
          p_c011 => c.col011,
          p_c012 => c.col012,
          p_c013 => c.col013,
          p_c014 => c.col014,
          p_c015 => c.col015,
          p_c016 => c.col016,
          p_c017 => c.col017,
          p_c018 => c.col018,
          p_c019 => c.col019,
          p_c020 => c.col020
          );
        end loop; 
    end loop;
    
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_parse_to_collection;

procedure p_restore_locations
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_locations';
    v_params logger.tab_param;

  begin
    logger.log('START', v_scope, null, v_params);

    for i in (
      select c001, c002
      FROM APEX_collections
      WHERE collection_name = 'LOCATIONS_BACKUP' 
    )
    loop
      insert into LOCATIONS (ID, NAME)
      values (i.c001, i.c002);
    end loop;

    logger.log('Przywrócono locations.', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_locations;

procedure p_restore_lending
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_lending';
    v_params logger.tab_param;

  begin
    logger.log('START', v_scope, null, v_params);

    for i in (
      select c001, c002, c003, c004, c005, c006
      FROM APEX_collections
      WHERE collection_name = 'LENDING_BACKUP' 
    )
    loop
      insert into BOOK_LENDING (ID, BOOK_ID, START_DATE, END_DATE, PERSON, EMAIL)
      values (i.c001, i.c002, i.c003, i.c004, i.c005, i.c006);
    end loop;

    logger.log('Przywrócono lending.', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_lending;

procedure p_restore_history
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_history';
    v_params logger.tab_param;

  begin
    logger.log('START', v_scope, null, v_params);

    for i in (
      select c001, c002, c003, c004, c005
      FROM APEX_collections
      WHERE collection_name = 'HISTORY_BACKUP' 
    )
    loop
      insert into HISTORY (ID, ACTION_ID, BOOK_ID, USER_NAME, TIME)
      values (i.c001, i.c002, i.c003, i.c004, i.c005);
    end loop;

    logger.log('Przywrócono history.', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_history;

procedure p_restore_genres
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_genres';
    v_params logger.tab_param;

  begin
    logger.log('START', v_scope, null, v_params);

    for i in (
      select c001, c002
      FROM APEX_collections
      WHERE collection_name = 'GENRES_BACKUP' 
    )
    loop
      insert into BOOK_GENRES (ID, NAME)
      values (i.c001, i.c002);
    end loop;

    logger.log('Przywrócono genres.', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_genres;

procedure p_restore_books
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_books';
    v_params logger.tab_param;

  begin
    logger.log('START', v_scope, null, v_params);

    for i in (
      select c001, c002, c003, c004, c005, c006, c007, c008, c009, c013
      FROM APEX_collections
      WHERE collection_name = 'BOOKS_BACKUP' 
    )
    loop
      insert into BOOKS (ID, TITLE, AUTHOR, ISBN, YEAR, GENRE_ID, LOCATION_ID, SCORE, DESCRIPTION, DELETED)
      values (i.c001, i.c002, i.c003, i.c004, i.c005, i.c006, i.c007, i.c008, i.c009, i.c013);
    end loop;
      for c in (
        select * from MY_TEMP_FILES where FILE_NAME like 'covers/%'
      )
      loop
        update BOOKS
        set COVER = c.FILE_CONTENT,
            MIME_TYPE = c.MIME_TYPE,
            FILE_NAME = SUBSTR(c.FILE_NAME, 8)
        where ID = TO_NUMBER(SUBSTR(SUBSTR(c.FILE_NAME, INSTR(c.FILE_NAME, '/') + 1), 1, INSTR(SUBSTR(c.FILE_NAME, INSTR(c.FILE_NAME, '/') + 1), '_') - 1));
      end loop;

    logger.log('Przywrócono books.', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_books;

procedure p_restore_actions
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_actions';
    v_params logger.tab_param;

  begin
    logger.log('START', v_scope, null, v_params);

    for i in (
      select c001, c002
      FROM APEX_collections
      WHERE collection_name = 'ACTIONS_BACKUP' 
    )
    loop
      insert into ACTIONS (ACTION, DESCRIPTION)
      values (i.c001, i.c002);
    end loop;

    logger.log('Przywrócono actions.', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_actions;

end pkg_backups;
/