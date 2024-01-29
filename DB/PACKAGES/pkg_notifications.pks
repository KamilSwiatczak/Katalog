
create or replace package pkg_notifications
as



procedure p_create_email_notification(
  pi_email in notifications.email%type,
  pi_template_static_id in varchar2,
  pi_placeholders in clob
);

procedure p_create_app_notification(
  pi_notification_text in notifications.notification_text%type,
  pi_receiver in notifications.receiver%type
);

procedure p_create_appemail_notification(
  pi_email in notifications.email%type,
  pi_template_static_id in varchar2,
  pi_placeholders in clob,
  pi_notification_text in notifications.notification_text%type,
  pi_receiver in notifications.receiver%type
);

procedure p_send_email_notification(
  pi_id in notifications.id%type
);

  

end pkg_notifications;
/