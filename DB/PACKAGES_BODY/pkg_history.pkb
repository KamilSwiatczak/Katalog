
create or replace package body pkg_history
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_history') || '.';



procedure p_history_log(
  pi_action in history.action_id%type,
  pi_book_id in history.book_id%type
  )
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_history_log';
  v_params logger.tab_param;

begin
   if pi_action not in ('NEW', 'UPDATE', 'DELETE', 'RETURN', 'RESTORE', 'LEND') then
      raise_application_error(-20005, 'Nieprawidłowa akcja.');
    end if;
  logger.append_param(v_params, 'pi_action', pi_action);
  logger.append_param(v_params, 'pi_book_id', pi_book_id);
  logger.log('START', v_scope, null, v_params);

  INSERT INTO history (action_id, book_id, user_name, time)
  VALUES (pi_action, pi_book_id, apex_custom_auth.get_username, LOCALTIMESTAMP);

  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_history_log;

  

end pkg_history;