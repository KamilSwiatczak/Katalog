create or replace package pkg_history
as


procedure p_history_log(
  pi_action in history.action_id%type,
  pi_book_id in history.book_id%type,
  pi_wishbook_id in history.wishbook_id%type,
  pi_section in history.section%type
  );

    

end pkg_history;
/