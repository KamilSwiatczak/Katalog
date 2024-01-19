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
  pkg_history.p_history_log(pi_action => 'REMOVE_WISHLIST_BOOK', pi_book_id => pi_id);
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
  pkg_history.p_history_log(pi_action => 'REMOVE_WISHLISTPRICE', pi_book_id => pi_id);
  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_delete_price;

procedure p_wishlist_books_create_update(
      pi_id in wishlist_books.id%type,
      pi_title in wishlist_books.title%type,
      pi_author in wishlist_books.author%type,
      pi_isbn in wishlist_books.isbn%type,
      pi_link in wishlist_books.link%type
  )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_wishlist_books_create_update';
    v_params logger.tab_param;
    v_id wishlist_books.id%type;
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.append_param(v_params, 'pi_title', pi_title);
    logger.append_param(v_params, 'pi_author', pi_author);
    logger.append_param(v_params, 'pi_isbn', pi_isbn);
    logger.append_param(v_params, 'pi_link', pi_link);
    logger.log('START', v_scope, null, v_params);

    if pi_id is null then
      INSERT INTO wishlist_books (title, author, isbn, link)
      VALUES (pi_title, pi_author, pi_isbn, pi_link)
      returning id into v_id;
      pkg_history.p_history_log(pi_action => 'NEW_WISHLIST_BOOK', pi_book_id => v_id);
      logger.log('Książka '||pi_title||' została dodana do listy życzeń.', v_scope);
    else update wishlist_books
          set title=pi_title,
              author=pi_author,
              isbn=pi_isbn,
              link=pi_link
          where ID = pi_id;
          pkg_history.p_history_log(pi_action => 'EDIT_WISHLIST_BOOK', pi_book_id => pi_id);
          logger.log('Książka '||pi_title||' z listy życzeń została edytowana.', v_scope);
    end if;
  logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_wishlist_books_create_update;

procedure p_wishlist_prices_create_update(
      pi_id in wishlist_prices.id%type,
      pi_wishbook_id in wishlist_prices.wishbook_id%type,
      pi_price in wishlist_prices.price%type
      )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_wishlist_prices_create_update';
    v_params logger.tab_param;

  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.append_param(v_params, 'pi_wishbook_id', pi_wishbook_id);
    logger.append_param(v_params, 'pi_price', pi_price);
    logger.log('START', v_scope, null, v_params);

    if pi_id is null then
      INSERT INTO wishlist_prices (wishbook_id, price, time)
      VALUES (pi_wishbook_id, pi_price, LOCALTIMESTAMP);
      pkg_history.p_history_log(pi_action => 'NEW_WISHLIST_PRICE', pi_book_id => pi_wishbook_id);
      logger.log('Cena '||pi_id||' została dodana.', v_scope);
    else update wishlist_prices
          set wishbook_id=pi_wishbook_id,
              price=pi_price,
              time=LOCALTIMESTAMP
          where ID = pi_id;
          pkg_history.p_history_log(pi_action => 'EDIT_WISHLIST_PRICE', pi_book_id => pi_wishbook_id);
          logger.log('Cena '||pi_id||' została edytowana.', v_scope);
    end if;
  logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_wishlist_prices_create_update;

end pkg_wishlist;