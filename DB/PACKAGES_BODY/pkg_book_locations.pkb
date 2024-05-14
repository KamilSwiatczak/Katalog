create or replace package body pkg_book_locations
as
gc_scope_prefix constant varchar2(31) := lower('pkg_books_genres') || '.';
TYPE locations_table_type IS RECORD(
  id locations.id%TYPE,
  name locations.name%type,
  current_count number,
  max_count locations.capacity%type
);
TYPE locations_table IS TABLE OF locations_table_type;



function f_check_location_exists(
  pi_name in locations.name%type
) return boolean
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'f_check_location_exists';
  v_params logger.tab_param;
  v_location_count number;
begin
  logger.append_param(v_params, 'pi_name', pi_name);
  logger.log('START', v_scope, null, v_params);

  select count(*) into v_location_count
  from LOCATIONS
  where name = pi_name;

  logger.log('END', v_scope);
  return v_location_count > 0;
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end f_check_location_exists;


  

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


      if pi_name is not null then
        if not f_check_location_exists(pi_name) then
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


function f_check_if_full
    return
      APEX_T_NUMBER
    as
      v_scope logger_logs.scope%type := gc_scope_prefix || 'f_check_if_full';
      v_params logger.tab_param;
      v_return APEX_T_NUMBER := APEX_T_NUMBER();
      v_table locations_table;
    begin
      logger.log('START', v_scope, null, v_params);

      select l.id, l.name, count(b.id), capacity 
      bulk collect into v_table
      from locations l 
      left join books b on l.id = b.location_id 
      group by l.id, l.name, capacity;


      for i in v_table.first..v_table.last 
      loop
        logger.log(v_table(i).name);
        if v_table(i).current_count >= v_table(i).max_count then 
          v_return.extend();
          v_return(v_return.last) := v_table(i).id;
          logger.log(v_table(i).id, v_scope);
        end if;
      end loop;
      logger.log('END', v_scope);
      return v_return;
    exception
      when others then
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
end f_check_if_full;

  


end pkg_book_locations;
/