create or replace package pkg_history
as


procedure p_history_log(
  pi_action in history.action_id%type,
  pi_book_id in history.book_id%type,
	pi_user in history.user_name%type,
	pi_time in history.time%type
);

    

end pkg_history;