create or replace package pkg_wishlist
as


procedure p_delete_wishbook(
  pi_id in wishlist_books.id%type
);
procedure p_delete_price(
  pi_id in wishlist_prices.id%type
);
    

end pkg_wishlist;