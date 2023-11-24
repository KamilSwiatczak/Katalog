
create or replace package body pkg_book_lending
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_book_lending') || '.';



-- Opis Procedury
procedure p_create_book_lending(
  pi_book_id in book_lending.book_id%type,
  pi_person in book_lending.person%type,
  pi_date in book_lending.start_date%type
  )
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_create_book_lending';
  v_params logger.tab_param;

begin
  logger.append_param(v_params, 'pi_book_id', pi_book_id);
  logger.append_param(v_params, 'pi_person', pi_person);
  logger.append_param(v_params, 'pi_date', pi_date);
  logger.log('START', v_scope, null, v_params);

  insert into book_lending (book_id, person, start_date)
  values (pi_book_id, pi_person, pi_date);

  logger.log('Książka wypożyczona', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_create_book_lending;

    

end pkg_book_lending;

