create or replace package pkg_backups
as


procedure p_backups_export;
procedure p_books_export;
procedure p_location_export;
procedure p_lending_export;
procedure p_genres_export;
procedure p_history_export;
procedure p_actions_export;
procedure p_wishlist_books_export;
procedure p_wishlist_prices_export;
procedure p_sections_export;
procedure p_notifications_export;
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
procedure p_restore_wishlist_books;
procedure p_restore_wishlist_prices;
procedure p_restore_sections;
procedure p_restore_notifications;
procedure p_add_external_file(
  pi_backup backups.backup%type,
  pi_mime_type backups.mime_type%type
  );
procedure p_remove_backup(
  pi_id in backups.id%type
);

  

end pkg_backups;
/