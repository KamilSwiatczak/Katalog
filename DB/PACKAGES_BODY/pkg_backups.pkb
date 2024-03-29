create or replace package body pkg_backups
as
  gc_scope_prefix constant varchar2(31) := lower('pkg_backups') || '.';
  TYPE locations_record_type IS RECORD(
    id locations.id%type, 
    name locations.name%type, 
    capacity locations.capacity%type);
  TYPE locations_table_type IS TABLE OF locations_record_type;
  TYPE temp_files_type IS TABLE OF MY_TEMP_FILES%ROWTYPE;
  TYPE lending_record_type IS RECORD(
    id book_lending.id%type, 
    book_id book_lending.book_id%type, 
    start_date book_lending.start_date%type, 
    end_date book_lending.end_date%type, 
    person book_lending.person%type, 
    email book_lending.email%type);
  TYPE lending_table_type IS TABLE OF lending_record_type;
  TYPE history_record_type IS RECORD (
    id history.id%type, 
    action_id history.action_id%type, 
    book_id history.book_id%type, 
    user_name history.user_name%type, 
    wishbook_id history.wishbook_id%type, 
    section history.section%type, 
    action_date history.action_date%type);
  TYPE history_table_type IS TABLE OF history_record_type;
  TYPE genres_record_type IS RECORD (
    id book_genres.id%TYPE,
    name book_genres.name%TYPE);
  TYPE genres_table_type IS TABLE OF genres_record_type;
  TYPE actions_record_type IS RECORD (
    action actions.action%TYPE,
    description actions.description%TYPE);
  TYPE actions_table_type IS TABLE OF actions_record_type;
  TYPE wishlist_books_record_type IS RECORD(
    id wishlist_books.id%TYPE, 
    title wishlist_books.title%TYPE, 
    author wishlist_books.author%TYPE, 
    isbn wishlist_books.isbn%TYPE, 
    link wishlist_books.link%TYPE, 
    desired_price wishlist_books.desired_price%TYPE, 
    date_added wishlist_books.date_added%TYPE);
  TYPE wishlist_books_table_type IS TABLE OF wishlist_books_record_type;
  TYPE wishlist_prices_record_type IS RECORD(
    id wishlist_prices.id%TYPE, 
    wishbook_id wishlist_prices.wishbook_id%TYPE, 
    price wishlist_prices.price%TYPE, 
    date_added wishlist_prices.date_added%TYPE);
  TYPE wishlist_prices_table_type IS TABLE OF wishlist_prices_record_type;
  TYPE sections_record_type IS RECORD(
    section sections.section%type, 
    description sections.description%type);
  TYPE sections_table_type IS TABLE OF sections_record_type;
  TYPE notifications_record_type IS RECORD(
    id notifications.id%type,
    notification_text notifications.notification_text%type, 
    email_html_body notifications.email_html_body%type, 
    receiver notifications.receiver%type, 
    email notifications.email%type, 
    type notifications.type%type, 
    read notifications.read%type, 
    sent notifications.sent%type, 
    email_subject notifications.email_subject%type, 
    email_plain_body notifications.email_plain_body%type,
    date_sent notifications.date_sent%type);
  TYPE notifications_table_type IS TABLE OF notifications_record_type;
  TYPE system_notifications_users_record_type IS RECORD(
    id system_notifications_users.id%type, 
    user_name system_notifications_users.user_name%type, 
    email system_notifications_users.email%type);
  TYPE system_notifications_users_table_type IS TABLE OF system_notifications_users_record_type;
  TYPE books_record_type IS RECORD (
    id           books.id%TYPE,
    title        books.title%TYPE,
    author       books.author%TYPE,
    isbn         books.isbn%TYPE,
    year         books.year%TYPE,
    genre_id     books.genre_id%TYPE,
    location_id  books.location_id%TYPE,
    score        books.score%TYPE,
    description  books.description%TYPE,
    deleted      books.DELETED%TYPE,
    publisher    books.PUBLISHER%TYPE,
    language     books.LANGUAGE%TYPE,
    date_added   books.date_added%TYPE);
  TYPE books_table_type IS TABLE OF books_record_type;


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
        p_sql_query   => 'select id, name from book_genres');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'genres/genres_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano book_lending', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
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
        p_sql_query   => 'select action, description from actions');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'actions/actions_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano actions', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
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
        p_sql_query   => 'select id, book_id, start_date, end_date, person, email from book_lending');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'lending/lending_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano book_lending', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
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
        p_sql_query   => 'select id, name, capacity from locations');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'locations/location_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano locations', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        apex_exec.close( v_context );
        raise;
END p_location_export;    

PROCEDURE p_sections_export 
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_sections_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select section, description from sections');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'sections/sections_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano sections', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        apex_exec.close( v_context );
        raise;
END p_sections_export; 

PROCEDURE p_notifications_export 
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_notifications_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select id, notification_text, email_html_body, receiver, email, type, read, sent, email_subject, email_plain_body, date_sent from notifications');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'notifications/notifications_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano notifications', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        apex_exec.close( v_context );
        raise;
END p_notifications_export; 

PROCEDURE p_books_export as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_books_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select id, title, author, isbn, year, genre_id, location_id, score, description, deleted, publisher, language, date_added from books');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'books/books_backup'
                    );

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano books', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
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
        p_sql_query   => 'select id, user_name, backup, mime_type, file_name from backups');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'backups/backups_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano backups', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
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
        p_sql_query   => 'select id, action_id, book_id, user_name, wishbook_id, section, action_date from history');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'history/history_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano history', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        apex_exec.close( v_context );
        raise;
END p_history_export;

PROCEDURE p_wishlist_books_export as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_wishlist_books_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select id, title, author, isbn, link, desired_price, date_added from wishlist_books');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'wishlist_books/wishlist_books_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano wishlist_books', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        apex_exec.close( v_context );
        raise;
END p_wishlist_books_export;


PROCEDURE p_wishlist_prices_export as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_wishlist_prices_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select id, wishbook_id, price, date_added from wishlist_prices;');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'wishlist_prices/wishlist_prices_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano wishlist_prices', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        apex_exec.close( v_context );
        raise;
END p_wishlist_prices_export;

PROCEDURE p_system_notifications_users_export as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_system_notifications_users_export';
    v_params logger.tab_param;
    v_context apex_exec.t_context;
    v_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    v_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 'select id, user_name, email from system_notifications_users');

    v_export := apex_data_export.export (
                    p_context   => v_context,
                    p_format    => apex_data_export.c_format_xlsx,
                    p_file_name => 'system_notifications_users/system_notifications_users_backup');

    apex_exec.close( v_context );
    
    pkg_temp_files.p_insert_files(v_export.file_name, v_export.content_blob, v_export.mime_type);

    logger.log('Eksportowano system_notifications_users', v_scope);

  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        apex_exec.close( v_context );
        raise;
END p_system_notifications_users_export;

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
    pkg_backups.p_wishlist_books_export;
    pkg_backups.p_wishlist_prices_export;
    pkg_backups.p_sections_export;
    pkg_backups.p_notifications_export;
    pkg_backups.p_system_notifications_users_export;    


    pkg_temp_files.p_zip_temp_files(po_zipped_blob => v_zip_file);

    insert into backups (user_name, backup, mime_type, file_name)
    values (apex_custom_auth.get_username, v_zip_file, 'application/zip', 'backup_'||SYSDATE||'.zip');

    pkg_temp_files.p_clear_temp_files;

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
          pkg_temp_files.p_insert_files(v_files(i), v_unzipped_file, null);
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

    p_clear_all_tables;
    
    p_restore_system_notifications_users;
    p_restore_notifications;
    p_restore_sections;
    p_restore_locations;
    p_restore_genres;
    p_restore_actions;
    p_restore_books;
    p_restore_lending;
    p_restore_wishlist_books;
    p_restore_wishlist_prices;
    p_restore_history;

    pkg_temp_files.p_clear_temp_files;

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
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'WISHLIST_BOOKS_BACKUP');
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'WISHLIST_PRICES_BACKUP');
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'SECTIONS_BACKUP');
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'NOTIFICATIONS_BACKUP');
    APEX_COLLECTION.TRUNCATE_COLLECTION(
    p_collection_name => 'SYSTEM_NOTIFICATIONS_USERS_BACKUP');
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
    v_table_name varchar2(1000); 
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
    v_locations_backup locations_table_type;
    
  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002, c003
    BULK COLLECT INTO v_locations_backup
    FROM APEX_collections
    WHERE collection_name = 'LOCATIONS_BACKUP'; 
      
    FORALL i IN 1..v_locations_backup.COUNT
    insert into LOCATIONS (ID, NAME, CAPACITY)
    values (v_locations_backup(i).ID, v_locations_backup(i).NAME, v_locations_backup(i).CAPACITY);

    logger.log('Przywrócono locations.', v_scope);
    exception
      when others then
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
end p_restore_locations;

procedure p_restore_system_notifications_users
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_system_notifications_users';
    v_params logger.tab_param;
    v_system_notifications_users_backup system_notifications_users_table_type;
    
  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002, c003
    BULK COLLECT INTO v_system_notifications_users_backup
    FROM APEX_collections
    WHERE collection_name = 'SYSTEM_NOTIFICATIONS_USERS_BACKUP'; 
      
    FORALL i IN 1..v_system_notifications_users_backup.COUNT
    insert into SYSTEM_NOTIFICATIONS_USERS (ID, USER_NAME, EMAIL)
    values (v_system_notifications_users_backup(i).ID, v_system_notifications_users_backup(i).USER_NAME, v_system_notifications_users_backup(i).EMAIL);

    logger.log('Przywrócono system_notifications_users.', v_scope);
    exception
      when others then
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
end p_restore_system_notifications_users;


procedure p_restore_sections
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_sections';
    v_params logger.tab_param;
    v_sections_backup sections_table_type;
    
  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002
    BULK COLLECT INTO v_sections_backup
    FROM APEX_collections
    WHERE collection_name = 'SECTIONS_BACKUP'; 
      
    FORALL i IN 1..v_sections_backup.COUNT
    insert into SECTIONS (SECTION, DESCRIPTION)
    values (v_sections_backup(i).SECTION, v_sections_backup(i).DESCRIPTION);

    logger.log('Przywrócono sections.', v_scope);
    exception
      when others then
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
end p_restore_sections;

procedure p_restore_notifications
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_notifications';
    v_params logger.tab_param;
    v_notifications_backup notifications_table_type;
    
  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002, c003, c004, c005, c006, c007, c008, c009, c010, c011
    BULK COLLECT INTO v_notifications_backup
    FROM APEX_collections
    WHERE collection_name = 'NOTIFICATIONS_BACKUP'; 
      
    FORALL i IN 1..v_notifications_backup.COUNT
    insert into NOTIFICATIONS (ID, NOTIFICATION_TEXT, EMAIL_HTML_BODY, RECEIVER, EMAIL, TYPE, READ, SENT, EMAIL_SUBJECT, EMAIL_PLAIN_BODY, DATE_SENT)
    values (v_notifications_backup(i).ID, 
            v_notifications_backup(i).NOTIFICATION_TEXT,
            v_notifications_backup(i).EMAIL_HTML_BODY, 
            v_notifications_backup(i).RECEIVER, 
            v_notifications_backup(i).EMAIL, 
            v_notifications_backup(i).TYPE, 
            v_notifications_backup(i).READ,
            v_notifications_backup(i).SENT, 
            v_notifications_backup(i).EMAIL_SUBJECT,
            v_notifications_backup(i).EMAIL_PLAIN_BODY,
            v_notifications_backup(i).DATE_SENT
            );

    logger.log('Przywrócono notifications.', v_scope);
    exception
      when others then
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
end p_restore_notifications;


procedure p_restore_lending
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_lending';
    v_params logger.tab_param;
    v_lending_backup lending_table_type;

  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002, c003, c004, c005, c006
    BULK COLLECT INTO v_lending_backup
    FROM APEX_collections
    WHERE collection_name = 'LENDING_BACKUP'; 
    
    FORALL i IN 1..v_lending_backup.COUNT
    insert into BOOK_LENDING (ID, BOOK_ID, START_DATE, END_DATE, PERSON, EMAIL)
    values (v_lending_backup(i).ID, v_lending_backup(i).BOOK_ID, v_lending_backup(i).START_DATE, 
            v_lending_backup(i).END_DATE, v_lending_backup(i).PERSON, v_lending_backup(i).EMAIL);

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
    v_history_backup history_table_type;
  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002, c003, c004, c005, c006, c007
    BULK COLLECT INTO v_history_backup
    FROM APEX_collections
    WHERE collection_name = 'HISTORY_BACKUP'; 
    
    FORALL i IN 1..v_history_backup.COUNT
    insert into HISTORY (ID, ACTION_ID, BOOK_ID, USER_NAME, ACTION_DATE, WISHBOOK_ID, SECTION)
    values (v_history_backup(i).ID, v_history_backup(i).ACTION_ID, v_history_backup(i).BOOK_ID, v_history_backup(i).USER_NAME, 
            v_history_backup(i).ACTION_DATE, v_history_backup(i).wishbook_id, v_history_backup(i).section);
    

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
    v_genres_backup genres_table_type;

  begin
    logger.log('START', v_scope, null, v_params);

      select c001, c002
      BULK COLLECT INTO v_genres_backup
      FROM APEX_collections
      WHERE collection_name = 'GENRES_BACKUP'; 
      
      FORALL i IN 1..v_genres_backup.COUNT
      insert into BOOK_GENRES (ID, NAME)
      values (v_genres_backup(i).ID, v_genres_backup(i).NAME);
      

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
    v_books_backup books_table_type;
    v_temp_files temp_files_type;
  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002, c003, c004, c005, c006, c007, c008, c009, c010, c011, c012, c013
    BULK COLLECT INTO v_books_backup
    FROM APEX_collections
    WHERE collection_name = 'BOOKS_BACKUP'; 
    
    FORALL i IN 1..v_books_backup.COUNT
    INSERT INTO BOOKS (ID, TITLE, AUTHOR, ISBN, YEAR, GENRE_ID, LOCATION_ID, SCORE, DESCRIPTION, DELETED, PUBLISHER, LANGUAGE, DATE_ADDED)
    VALUES (
      v_books_backup(i).ID, v_books_backup(i).TITLE, v_books_backup(i).AUTHOR,
      v_books_backup(i).ISBN, v_books_backup(i).YEAR, v_books_backup(i).GENRE_ID,
      v_books_backup(i).LOCATION_ID, v_books_backup(i).SCORE, v_books_backup(i).DESCRIPTION,
      v_books_backup(i).DELETED, v_books_backup(i).PUBLISHER, v_books_backup(i).LANGUAGE, v_books_backup(i).DATE_ADDED
      );

    SELECT * 
    BULK COLLECT INTO v_temp_files 
    FROM MY_TEMP_FILES 
    WHERE FILE_NAME LIKE 'covers/%';

    FORALL i IN 1..v_temp_files.COUNT
      UPDATE BOOKS
      SET COVER = v_temp_files(i).FILE_CONTENT,
          MIME_TYPE = v_temp_files(i).MIME_TYPE,
          FILE_NAME = SUBSTR(v_temp_files(i).FILE_NAME, 8)
          WHERE TITLE = SUBSTR(v_temp_files(i).FILE_NAME, INSTR(v_temp_files(i).FILE_NAME, '/') + 1, INSTR(v_temp_files(i).FILE_NAME, '.') - INSTR(v_temp_files(i).FILE_NAME, '/') - 1);
          --wycięcie z formatu id_title.jpg: WHERE ID = TO_NUMBER(SUBSTR(SUBSTR(v_temp_files(i).FILE_NAME, INSTR(v_temp_files(i).FILE_NAME, '/') + 1), 1, INSTR(SUBSTR(v_temp_files(i).FILE_NAME, INSTR(v_temp_files(i).FILE_NAME, '/') + 1), '_') - 1));      

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
    v_actions_backup actions_table_type;
  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002
    BULK COLLECT INTO v_actions_backup
    FROM APEX_collections
    WHERE collection_name = 'ACTIONS_BACKUP'; 

    FORALL i IN 1..v_actions_backup.COUNT
    insert into ACTIONS (ACTION, DESCRIPTION)
    values (v_actions_backup(i).ACTION, v_actions_backup(i).DESCRIPTION);


    logger.log('Przywrócono actions.', v_scope);
    exception
      when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_actions;

procedure p_restore_wishlist_books
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_wishlist_books';
    v_params logger.tab_param;
    v_wishlist_books_backup wishlist_books_table_type;
  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002, c003, c004, c005, REPLACE(c006, '.', ','), c007
    BULK COLLECT INTO v_wishlist_books_backup
    FROM APEX_collections
    WHERE collection_name = 'WISHLIST_BOOKS_BACKUP'; 

    FORALL i IN 1..v_wishlist_books_backup.COUNT
    insert into WISHLIST_BOOKS (ID, TITLE, AUTHOR, ISBN, LINK, DESIRED_PRICE, DATE_ADDED)
    values (v_wishlist_books_backup(i).ID,
            v_wishlist_books_backup(i).TITLE,
            v_wishlist_books_backup(i).AUTHOR,
            v_wishlist_books_backup(i).ISBN,
            v_wishlist_books_backup(i).LINK,
            v_wishlist_books_backup(i).DESIRED_PRICE,
            v_wishlist_books_backup(i).DATE_ADDED
            );


    logger.log('Przywrócono wishlist_books.', v_scope);
    exception
      when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_wishlist_books;

procedure p_restore_wishlist_prices
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_wishlist_prices';
    v_params logger.tab_param;
    v_wishlist_prices_backup wishlist_prices_table_type;
  begin
    logger.log('START', v_scope, null, v_params);

    select c001, c002, REPLACE(c003, '.', ','), c004
    BULK COLLECT INTO v_wishlist_prices_backup
    FROM APEX_collections
    WHERE collection_name = 'WISHLIST_PRICES_BACKUP'; 

    FORALL i IN 1..v_wishlist_prices_backup.COUNT
    insert into WISHLIST_PRICES (ID, WISHBOOK_ID, PRICE, DATE_ADDED)
    values (v_wishlist_prices_backup(i).ID, 
            v_wishlist_prices_backup(i).WISHBOOK_ID, 
            v_wishlist_prices_backup(i).PRICE, 
            v_wishlist_prices_backup(i).DATE_ADDED);

    logger.log('Przywrócono wishlist_prices.', v_scope);
    exception
      when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_wishlist_prices;

procedure p_add_external_file(
    pi_backup backups.backup%type,
    pi_mime_type backups.mime_type%type
    )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_add_external_file';
    v_params logger.tab_param;
  
  begin
    logger.append_param(v_params, 'pi_backup', length(pi_backup));
    logger.append_param(v_params, 'pi_mime_type', pi_mime_type);
    logger.log('START', v_scope, null, v_params);
  
  
    insert into backups (user_name, backup, mime_type, file_name)
    values (apex_custom_auth.get_username, pi_backup, pi_mime_type, 'external_backup_'||SYSDATE||'.zip');
  
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_add_external_file;


procedure p_remove_backup(
    pi_id in backups.id%type
  )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_remove_backup';
    v_params logger.tab_param;

  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.log('START', v_scope, null, v_params);

        DELETE FROM backups 
        WHERE ID=pi_id;

    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_remove_backup;

procedure p_clear_all_tables
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_clear_all_tables';
    v_params logger.tab_param;

  begin

    logger.log('START', v_scope, null, v_params);

    delete from SYSTEM_NOTIFICATIONS_USERS;
    delete from NOTIFICATIONS;
    delete from BOOK_LENDING;
    delete from HISTORY;
    delete from BOOKS;
    delete from LOCATIONS;
    delete from BOOK_GENRES;
    delete from ACTIONS;
    delete from WISHLIST_PRICES;
    delete from WISHLIST_BOOKS;
    delete from SECTIONS;

    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_clear_all_tables;

end pkg_backups;
/