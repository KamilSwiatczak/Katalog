  CREATE TABLE "SYSTEM_NOTIFICATIONS_USERS" 
   (	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE, 
	"USER_NAME" VARCHAR2(4000 CHAR) NOT NULL ENABLE, 
	"EMAIL" VARCHAR2(255 CHAR) NOT NULL ENABLE, 
	"CREATE_DATE" DATE DEFAULT SYSDATE NOT NULL ENABLE, 
	 CONSTRAINT "SYSTEM_NOTIFICATIONS_USERS_ID_PK" PRIMARY KEY ("ID")
  USING INDEX  ENABLE
   ) ;

  CREATE OR REPLACE EDITIONABLE TRIGGER "SYSTEM_NOTIFICATIONS_USERS_CREATE_DATE" 
before
insert on "SYSTEM_NOTIFICATIONS_USERS"
for each row
begin
    :NEW.CREATE_DATE := SYSDATE;
end;
/
ALTER TRIGGER "SYSTEM_NOTIFICATIONS_USERS_CREATE_DATE" ENABLE;