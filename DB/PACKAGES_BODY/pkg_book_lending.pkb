
create or replace package body pkg_book_lending
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_book_lending') || '.';




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
  pkg_history.p_history_log(pi_action => 'LEND', pi_book_id => pi_book_id);
  logger.log('Książka wypożyczona', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_create_book_lending;

    


procedure p_book_returning(
  pi_book_id IN book_lending.book_id%type,
  pi_date in book_lending.end_date%type
)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_book_returning';
  v_params logger.tab_param;
  v_count NUMBER;

begin
  logger.append_param(v_params, 'pi_book_id', pi_book_id);
  logger.log('START', v_scope, NULL, v_params);

  SELECT COUNT(*)
  INTO v_count
  FROM BOOK_LENDING
  WHERE book_id = pi_book_id;

  IF v_count = 0 THEN
    raise_application_error(-20001, 'Ta książka nie była wypożyczona.');
  ELSE
    UPDATE BOOK_LENDING
    SET end_date = pi_date
    WHERE book_id = pi_book_id AND end_date IS NULL;

    IF SQL%ROWCOUNT = 0 THEN
      raise_application_error(-20002, 'Ta książka jest zwrócona');
    ELSE
      pkg_history.p_history_log(pi_action => 'RETURN', pi_book_id => pi_book_id);
    END IF;
  END IF;

  logger.log('END', v_scope);
EXCEPTION
  WHEN OTHERS THEN
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, NULL, v_params);
    RAISE;
end p_book_returning;
  

end pkg_book_lending;