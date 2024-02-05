
create or replace package body pkg_notifications
as


  gc_scope_prefix constant varchar2(31) := lower('pkg_notifications') || '.';



procedure p_create_email_notification(
  pi_email in notifications.email%type,
  pi_template_static_id in varchar2,
  pi_placeholders in clob
  )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_create_email_notification';
    v_params logger.tab_param;
    v_subject notifications.email_subject%type;
    v_html notifications.EMAIL_HTML_BODY%type;
    v_text notifications.email_plain_body%type;

  begin
    logger.append_param(v_params, 'pi_email', pi_email);
    logger.append_param(v_params, 'pi_template_static_id', pi_template_static_id);
    logger.append_param(v_params, 'pi_placeholders', pi_placeholders);  
    logger.log('START', v_scope, null, v_params);

    apex_mail.prepare_template(
      p_static_id=>pi_template_static_id, 
      p_placeholders=>pi_placeholders, 
      p_subject=>v_subject, 
      p_html=>v_html, 
      p_text=>v_text
    );
    INSERT INTO notifications (EMAIL_HTML_BODY, EMAIL, TYPE, EMAIL_SUBJECT, EMAIL_PLAIN_BODY)
    VALUES (v_html, pi_email, '+EMAIL+', v_subject, v_text);

    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_create_email_notification;



procedure p_create_app_notification(
    pi_notification_text in notifications.notification_text%type,
    pi_receiver in notifications.receiver%type
  )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_create_app_notification';
    v_params logger.tab_param;

  begin
    logger.append_param(v_params, 'pi_notification_text', pi_notification_text);
    logger.append_param(v_params, 'pi_receiver', pi_receiver);
    logger.log('START', v_scope, null, v_params);

    INSERT INTO notifications (NOTIFICATION_TEXT, RECEIVER, TYPE)
    VALUES (pi_notification_text, pi_receiver, '+APP+');

    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_create_app_notification;



procedure p_create_appemail_notification(
    pi_email in notifications.email%type,
    pi_template_static_id in varchar2,
    pi_placeholders in clob,
    pi_receiver in notifications.receiver%type
  )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_create_appemail_notification';
    v_params logger.tab_param;
    v_subject notifications.email_subject%type;
    v_html notifications.EMAIL_HTML_BODY%type;
    v_text notifications.email_plain_body%type;
  begin
    logger.append_param(v_params, 'pi_email', pi_email);
    logger.append_param(v_params, 'pi_template_static_id', pi_template_static_id);
    logger.append_param(v_params, 'pi_placeholders', pi_placeholders);
    logger.append_param(v_params, 'pi_receiver', pi_receiver);
    logger.log('START', v_scope, null, v_params);

      apex_mail.prepare_template(
        p_static_id=>pi_template_static_id, 
        p_placeholders=>pi_placeholders, 
        p_subject=>v_subject, 
        p_html=>v_html, 
        p_text=>v_text
      );
      INSERT INTO notifications (EMAIL_HTML_BODY, EMAIL, TYPE, EMAIL_SUBJECT, NOTIFICATION_TEXT, RECEIVER, EMAIL_PLAIN_BODY)
      VALUES (v_html, pi_email, '+APP+EMAIL+', v_subject, v_text, pi_receiver, v_text);
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_create_appemail_notification;




procedure p_send_email_notification(
    pi_id in notifications.id%type
    )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_send_email_notification';
    v_params logger.tab_param;
    v_email_data notifications%rowtype;
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.log('START', v_scope, null, v_params);

    select * into v_email_data from notifications where id = pi_id;

    IF v_email_data.TYPE like '%+EMAIL+%' THEN
    APEX_MAIL.SEND (
      p_to=>v_email_data.email,
      p_from=>'test@katalog.com',
      p_body=>v_email_data.email_plain_body,
      p_body_html=>v_email_data.email_html_body,
      p_subj=>v_email_data.EMAIL_SUBJECT
    );
    UPDATE NOTIFICATIONS
    SET SENT = 'y'
    WHERE ID = pi_id;
    END IF;

    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_send_email_notification;

  

end pkg_notifications;
/