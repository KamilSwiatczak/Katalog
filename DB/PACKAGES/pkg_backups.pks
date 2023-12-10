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

end pkg_backups;
/