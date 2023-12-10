create or replace package body pkg_backups
as
  gc_scope_prefix constant varchar2(31) := lower('pkg_backups') || '.';


PROCEDURE p_genres_export as
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
                    p_file_name => 'genres_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content)
    values (v_export.file_name, v_export.content_blob);

    logger.log('Eksportowano book_lending', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( v_context );
        raise;
END p_genres_export;  




PROCEDURE p_actions_export as
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
                    p_file_name => 'actions_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content)
    values (v_export.file_name, v_export.content_blob);

    logger.log('Eksportowano actions', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( v_context );
        raise;
END p_actions_export;  




PROCEDURE p_lending_export as
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
                    p_file_name => 'lending_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content)
    values (v_export.file_name, v_export.content_blob);

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
                    p_file_name => 'location_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content)
    values (v_export.file_name, v_export.content_blob);

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
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select * from books');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'books_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content)
    values (v_export.file_name, v_export.content_blob);

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
                    p_file_name => 'backups_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content)
    values (v_export.file_name, v_export.content_blob);

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
                    p_file_name => 'history_backup');

    apex_exec.close( v_context );
    
    insert into my_temp_files (file_name, file_content)
    values (v_export.file_name, v_export.content_blob);

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

      for i  in ( select file_name, file_content
                    from MY_TEMP_FILES)
    loop
        apex_zip.add_file (
            p_zipped_blob => v_zip_file,
            p_file_name   => i.file_name,
            p_content     => i.file_content);
    end loop;

    apex_zip.finish (
        p_zipped_blob => v_zip_file );
insert into backups (user_name, time, backup)
values (apex_custom_auth.get_username, LOCALTIMESTAMP, v_zip_file);
  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_zip_backup;

  


end pkg_backups;
/