alter table "KAMIL"."BOOKS" add
("DELETED" CHAR(1 CHAR) default 'N' not null);
alter table "KAMIL"."BOOKS" add constraint
"BOOKS_DELETED_CON" check ( "DELETED" IN ('N', 'Y') );