create or replace package body pkg_book_locations
as
gc_scope_prefix constant varchar2(31) := lower('pkg_books_genres') || '.';




procedure p_create_edit_location(
  pi_id in locations.id%type,
  pi_name in locations.name%type)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_create_edit_location';
  v_params logger.tab_param;
  v_location_count number;

begin
  logger.append_param(v_params, 'pi_id', pi_id);
  logger.append_param(v_params, 'pi_name', pi_name);
  logger.log('START', v_scope, null, v_params);

    select count(1) into v_location_count
    from LOCATIONS
    where name = pi_name;
    if pi_name is not null then
      if v_location_count = 0 then
          if pi_id is null then
            INSERT INTO locations (name)
            VALUES (pi_name);
            else
              update locations
                set name=pi_name
              where ID = pi_id;
          end if;
        else
          raise_application_error(-20001, 'Lokalizacja o nazwie "' || pi_name || '" już istnieje.');
      end if;
    else raise_application_error(-20002, 'Lokalizacja musi mieć nazwę.');
  end if;      
  logger.log('Utworzono/edytowano' ||pi_name, v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_create_edit_location;




procedure p_remove_location(
  pi_id in locations.id%type)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_remove_location';
  v_params logger.tab_param;
  v_count NUMBER;
begin
  logger.append_param(v_params, 'pi_id', pi_id);
  logger.log('START', v_scope, null, v_params);
  
  SELECT COUNT(*)
  INTO v_count
  FROM BOOKS
  WHERE LOCATION_ID = pi_id;
  
  IF v_count = 0 THEN
    DELETE FROM locations
    WHERE ID = pi_id;
    logger.log('Lokalizacja usunięta', v_scope);
    ELSE
    logger.log('Deletion not possible as ID exists in BOOKS table', v_scope);
    RAISE_APPLICATION_ERROR(-20001, 'Nie można usunąć tej lokalizacji, ponieważ są do niej przypisane książki.');
  END IF;
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_remove_location;

    

end pkg_book_locations;
/