
create or replace package body pkg_temp_files
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_temp_files') || '.';



procedure p_insert_files(
    pi_name in my_temp_files.file_name%type,
    pi_content in my_temp_files.file_content%type,
    pi_type in my_temp_files.mime_type%type
  )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_insert_files';
    v_params logger.tab_param;

  begin
    logger.append_param(v_params, 'pi_name', pi_name);
    logger.append_param(v_params, 'pi_content', length(pi_content));
    logger.append_param(v_params, 'pi_type', pi_type);
    logger.log('START', v_scope, null, v_params);

    insert into my_temp_files (file_name, file_content, mime_type)
    values (pi_name, pi_content, pi_type);

    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_insert_files;



procedure p_clear_temp_files
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_clear_temp_files';
  v_params logger.tab_param;

begin
  logger.log('START', v_scope, null, v_params);

    delete from MY_TEMP_FILES;

  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_clear_temp_files;



procedure p_zip_temp_files(
  po_zipped_blob out blob 
)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_zip_temp_files';
  v_params logger.tab_param;
  v_zip_file blob;
begin
  logger.log('START', v_scope, null, v_params);

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
            p_file_name   => 'covers/'||c.title,
            --p_file_name   => 'covers/'||c.title||SUBSTR(c.file_name, INSTR(c.file_name, '.', -1)),
            p_content     => c.cover);
    end loop;            
  apex_zip.finish (
        p_zipped_blob => v_zip_file);
  po_zipped_blob := v_zip_file;
  logger.append_param(v_params, 'po_zipped_blob', length(po_zipped_blob));
  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_zip_temp_files;

  

end pkg_temp_files;
/