
create or replace package body pkg_history
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_history') || '.';



function f_action_verify(
  pi_action in actions.action%type)
return
  boolean
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'f_action_verify';
  v_params logger.tab_param;
  v_count number;
  v_return boolean;
begin
  logger.append_param(v_params, 'pi_action', pi_action);
  logger.log('START', v_scope, null, v_params);

  select count(*) 
  into v_count
  from actions
  where pi_action = action;
  if v_count = 1 then 
    v_return := true;
  else
    v_return := false;
  end if;
  logger.log('END', v_scope);
  return v_return;
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end f_action_verify;

  

procedure p_history_log(
  pi_action in history.action_id%type,
  pi_book_id in history.book_id%type
  )
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_history_log';
  v_params logger.tab_param;

begin

  logger.append_param(v_params, 'pi_action', pi_action);
  logger.append_param(v_params, 'pi_book_id', pi_book_id);
  logger.log('START', v_scope, null, v_params);
  if f_action_verify(pi_action) then
    INSERT INTO history (action_id, book_id, user_name, time)
    VALUES (pi_action, pi_book_id, apex_custom_auth.get_username, LOCALTIMESTAMP);
  else 
    RAISE_APPLICATION_ERROR(-20006, 'Błędna akcja'); 
  end if;
  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_history_log;



end pkg_history;