
create or replace package pkg_temp_files
as


procedure p_insert_files(
  pi_name in my_temp_files.file_name%type,
  pi_content in my_temp_files.file_content%type,
  pi_type in my_temp_files.mime_type%type
);

procedure p_clear_temp_files;

procedure p_zip_temp_files(
  po_zipped_blob out blob 
);

end pkg_temp_files;
/