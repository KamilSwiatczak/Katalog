create or replace package body pkg_wishlist
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_wishlist') || '.';
  gc_price_percentage constant number := 0.9;


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
  pkg_history.p_history_log(pi_action => 'REMOVE_WISHLIST_BOOK', pi_wishbook_id => pi_id, pi_book_id => null, pi_section => 'WISHLIST_BOOKS');
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
  pkg_history.p_history_log(pi_action => 'REMOVE_WISHLISTPRICE', pi_wishbook_id => pi_id, pi_book_id => null, pi_section => 'WISHLIST_BOOKS');
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
      pi_link in wishlist_books.link%type,
      pi_desired_price in wishlist_books.desired_price%type,
      pi_email in wishlist_books.email%type
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
    logger.append_param(v_params, 'pi_desired_price', pi_desired_price);
    logger.append_param(v_params, 'pi_email', pi_email);
    logger.log('START', v_scope, null, v_params);

    if pi_id is null then
      INSERT INTO wishlist_books (title, author, isbn, link, desired_price, email)
      VALUES (pi_title, pi_author, pi_isbn, pi_link, pi_desired_price, pi_email)
      returning id into v_id;
      pkg_history.p_history_log(pi_action => 'NEW_WISHLIST_BOOK', pi_wishbook_id => v_id, pi_book_id => null, pi_section => 'WISHLIST_BOOKS');
      logger.log('Książka '||pi_title||' została dodana do listy życzeń.', v_scope);
    else update wishlist_books
          set title=pi_title,
              author=pi_author,
              isbn=pi_isbn,
              link=pi_link,
              desired_price=pi_desired_price,
              email=pi_email
          where ID = pi_id;
          pkg_history.p_history_log(pi_action => 'EDIT_WISHLIST_BOOK', pi_wishbook_id => pi_id, pi_book_id => null, pi_section => 'WISHLIST_BOOKS');
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
      VALUES (pi_wishbook_id, pi_price, SYSDATE);
      pkg_history.p_history_log(pi_action => 'NEW_WISHLIST_PRICE', pi_wishbook_id => pi_wishbook_id, pi_book_id => null, pi_section => 'WISHLIST_BOOKS');
      logger.log('Cena '||pi_wishbook_id||' została dodana.', v_scope);
    else update wishlist_prices
          set wishbook_id=pi_wishbook_id,
              price=pi_price
          where ID = pi_id;
          pkg_history.p_history_log(pi_action => 'EDIT_WISHLIST_PRICE', pi_wishbook_id => pi_wishbook_id, pi_book_id => null, pi_section => 'WISHLIST_BOOKS');
          logger.log('Cena '||pi_wishbook_id||' została edytowana.', v_scope);
    end if;
  logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_wishlist_prices_create_update;


procedure p_get_lowest_price(
      pi_wishbook_id in wishlist_prices.wishbook_id%type,
      pi_link in wishlist_books.link%type
      )
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_get_lowest_price';
  v_params logger.tab_param;
  v_xml 	CLOB;
  v_price VARCHAR2(40);
begin
  logger.append_param(v_params, 'pi_wishbook_id', pi_wishbook_id);
  logger.append_param(v_params, 'pi_link', pi_link);
  logger.log('START', v_scope, null, v_params);

  v_xml := apex_web_service.make_rest_request(
    p_url => pi_link,
    p_http_method => 'GET');
  v_price := REGEXP_SUBSTR(v_xml, 'od <span class="cena_big2" id="best_price"></span>(\d+),<sup>(\d+)</sup> zł', 1, 1, NULL, 1) ||
        '.' ||
        REGEXP_SUBSTR(v_xml, 'od <span class="cena_big2" id="best_price"></span>(\d+),<sup>(\d+)</sup> zł', 1, 1, NULL, 2);
  pkg_wishlist.p_wishlist_prices_create_update(pi_id => null, pi_wishbook_id => pi_wishbook_id, pi_price => TO_NUMBER(v_price, '99.99', 'NLS_NUMERIC_CHARACTERS='',.'''));

  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_get_lowest_price;



procedure p_desired_price_notification(
  pi_id in wishlist_books.id%type)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_desired_price_notification';
  v_params logger.tab_param;
  type t_price_data is record(
    title wishlist_books.title%type,
    price wishlist_prices.price%type,
    desired_price wishlist_books.desired_price%type
  );
    v_price_data t_price_data;

begin
  logger.append_param(v_params, 'pi_id', pi_id);
  logger.log('START', v_scope, null, v_params);
  select b.title, p.price, b.desired_price
  into v_price_data.title, v_price_data.price, v_price_data.desired_price
  from wishlist_books b 
  join wishlist_prices p on b.ID = p.WISHBOOK_ID 
  where p.id = pi_id;

  for i in (select * from SYSTEM_NOTIFICATIONS_USERS)
    loop
  pkg_notifications.p_create_appemail_notification (
     pi_email => i.email,
     pi_template_static_id => 'DESIRED_PRICE_ACHIEVED',
     pi_receiver => i.user_name,
     pi_placeholders       => '{' ||
     '    "TITLE":'      || apex_json.stringify( v_price_data.title ) ||
     '   ,"PRICE":'     || apex_json.stringify( v_price_data.price ) ||
     '   ,"DESIRED_PRICE":' || apex_json.stringify( v_price_data.desired_price ) ||
     '}' );
    end loop;

  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_desired_price_notification;



procedure p_price_drop_below_average_notification(
  pi_wishbook_id in wishlist_prices.wishbook_id%type
)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_price_drop_below_average_notification';
  v_params logger.tab_param;
  v_30_average number;
  v_new_price wishlist_prices.price%type;
  v_title wishlist_books.title%type;

begin
  logger.append_param(v_params, 'pi_wishbook_id', pi_wishbook_id);
  logger.log('START', v_scope, null, v_params);
  
  select PRICE into v_new_price from WISHLIST_PRICES 
  where WISHBOOK_ID = pi_wishbook_id and TRUNC(TIME, 'DD') = TRUNC(SYSDATE, 'DD')
  order by id desc
  fetch FIRST 1 rows only;

  select  TITLE into v_title from WISHLIST_BOOKS
  where ID = pi_wishbook_id;

  SELECT AVG(PRICE) into v_30_average
    FROM (
    SELECT PRICE
    FROM WISHLIST_PRICES
    WHERE WISHBOOK_ID = pi_wishbook_id
    ORDER BY TIME DESC
    OFFSET 1 ROW
    FETCH FIRST 30 ROWS ONLY
  );
    logger.log('v_title:'||v_title, v_scope);
    logger.log('v_30_average:'||v_30_average, v_scope);
    logger.log('v_new_price:'||v_new_price, v_scope);
    logger.log('gc_price_percentage:'||gc_price_percentage, v_scope);
  if v_30_average IS NOT NULL and v_new_price <= v_30_average*gc_price_percentage then

  for i in (select * from SYSTEM_NOTIFICATIONS_USERS)
    loop
    pkg_notifications.p_create_appemail_notification (
        pi_email => i.email,
        pi_template_static_id => '10_DROP_PRICE_NOTIFICATION',
        pi_receiver => i.user_name,
        pi_placeholders       => '{' ||
        '    "TITLE":' || apex_json.stringify( v_title ) ||
        '   ,"PRICE":' || apex_json.stringify( v_new_price ) ||
        '}' );
    end loop;
  
    logger.log('Przygotowano email dla:'||v_title||'.', v_scope);
  end if;

  logger.log('END', v_scope);
exception
  when others then
    logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
    raise;
end p_price_drop_below_average_notification;

  

end pkg_wishlist;
/