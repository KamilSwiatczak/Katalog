create or replace package pkg_backups
as


procedure p_backups_export;
procedure p_books_export;
procedure p_location_export;
procedure p_lending_export;
procedure p_genres_export;
procedure p_history_export;
procedure p_actions_export;
procedure p_zip_backup;
procedure p_backup_restore (
    pi_zip_file in blob
);
procedure p_RESTORE_FROM_EXISTING_BACKUP(
  pi_backup_id backups.id%type
);
procedure p_parse_to_collection;
procedure p_restore_locations;
procedure p_restore_lending;
procedure p_restore_history;
procedure p_restore_genres;
procedure p_restore_actions;
procedure p_restore_books;

end pkg_backups;
/