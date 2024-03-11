
create or replace package body pkg_book_lending
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_book_lending') || '.';




procedure p_create_book_lending(
    pi_book_id in book_lending.book_id%type,
    pi_person in book_lending.person%type,
    pi_date in book_lending.start_date%type,
    pi_email in book_lending.email%type
    )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_create_book_lending';
    v_params logger.tab_param;

  begin
    logger.append_param(v_params, 'pi_book_id', pi_book_id);
    logger.append_param(v_params, 'pi_person', pi_person);
    logger.append_param(v_params, 'pi_date', pi_date);
    logger.append_param(v_params, 'pi_email', pi_email);
    logger.log('START', v_scope, null, v_params);

    insert into book_lending (book_id, person, start_date, email)
    values (pi_book_id, pi_person, pi_date, pi_email);
    pkg_history.p_history_log(pi_action => 'LEND', pi_book_id => pi_book_id, pi_wishbook_id => null, pi_section => 'LIBRARY_BOOKS');
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
        pkg_history.p_history_log(pi_action => 'RETURN', pi_book_id => pi_book_id, pi_wishbook_id => null, pi_section => 'LIBRARY_BOOKS');
      END IF;
    END IF;

    logger.log('END', v_scope);
  EXCEPTION
    WHEN OTHERS THEN
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, NULL, v_params);
      RAISE;
end p_book_returning;
  



procedure p_send_reminder(
    pi_id in book_lending.id%type)
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_send_reminder';
    v_params logger.tab_param;
    type t_lending_data is record(
      person book_lending.person%type,
      email  book_lending.email%type,
      title books.title%type,
      start_date book_lending.start_date%type
      );
    v_lending_data t_lending_data;
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.log('START', v_scope, null, v_params);
    select l.person, l.email, b.title, l.start_date
    into v_lending_data.person, v_lending_data.email, v_lending_data.title, v_lending_data.start_date
    from book_lending l 
    join books b on l.book_id = b.id 
    where l.id = pi_id;

    -- apex_mail.send (
    --     p_from=>'test@katalog.com',
    --     p_to=>v_lending_data.email,
    --     p_subj=>'Przypomnienie o zwrocie książki o tytule: '|| v_lending_data.title,
    --     p_body=>v_lending_data.person||', przypominamy o upłynięciu terminu wypożyczenia książki '|| v_lending_data.title||'. Była ona wypożyczona '|| to_char(v_lending_data.start_date, 'YYYY-MM-DD')
    -- );


    pkg_notifications.p_create_email_notification (
      pi_email                 => v_lending_data.email,
      pi_template_static_id => 'BOOK_REMINDER',
      pi_placeholders       => '{' ||
      '    "TITLE":'      || apex_json.stringify( v_lending_data.title ) ||
      '   ,"PERSON":'     || apex_json.stringify( v_lending_data.person ) ||
      '   ,"START_DATE":' || apex_json.stringify( v_lending_data.start_date, 'YYYY-MM-DD' ) ||
      '}' );

    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_send_reminder;

  

end pkg_book_lending;
/