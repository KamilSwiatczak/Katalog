create or replace package body pkg_wishlist
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_wishlist') || '.';


procedure p_delete_wishbook(
  pi_id in wishlist_books.id%type)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_delete_wishbook';
  v_params logger.tab_param;

begin
  logger.append_param(v_params, 'pi_id', pi_id);
  logger.log('START', v_scope, null, v_params);

      DELETE FROM wishlist_books 
      WHERE ID=pi_id;

  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_delete_wishbook;


procedure p_delete_price(
  pi_id in wishlist_prices.id%type
)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_delete_price';
  v_params logger.tab_param;

begin
  logger.append_param(v_params, 'pi_id', pi_id);
  logger.log('START', v_scope, null, v_params);

      DELETE FROM wishlist_prices 
      WHERE ID=pi_id;

  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_delete_price;

  
    

end pkg_wishlist;