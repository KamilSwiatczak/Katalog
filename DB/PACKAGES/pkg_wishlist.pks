create or replace package pkg_wishlist
as


procedure p_delete_wishbook(
  pi_id in wishlist_books.id%type
);
procedure p_delete_price(
  pi_id in wishlist_prices.id%type
);
procedure p_wishlist_books_create_update(
      pi_id in wishlist_books.id%type,
      pi_title in wishlist_books.title%type,
      pi_author in wishlist_books.author%type,
      pi_isbn in wishlist_books.isbn%type,
      pi_link in wishlist_books.link%type
);
procedure p_wishlist_prices_create_update(
      pi_id in wishlist_prices.id%type,
      pi_wishbook_id in wishlist_prices.wishbook_id%type,
      pi_price in wishlist_prices.price%type
      );
procedure p_get_lowest_price(
      pi_wishbook_id in wishlist_prices.wishbook_id%type,
      pi_link in wishlist_books.link%type
      );
end pkg_wishlist;