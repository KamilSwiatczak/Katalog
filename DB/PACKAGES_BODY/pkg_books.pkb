
create or replace package body pkg_books
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_books') || '.';




procedure p_book_create_update(
      pi_id in books.id%type,
      pi_title in books.title%type,
      pi_author in books.author%type,
      pi_isbn in books.isbn%type,
      pi_year in books.year%type,
      pi_genre_id in books.genre_id%type,
      pi_location_id in books.location_id%type,
      pi_score in books.score%type,
      pi_description in books.description%type,
      pi_cover in books.cover%type,
      pi_mime in books.MIME_TYPE%type,
      pi_file_name in books.FILE_NAME%type,
      pi_publisher in BOOKS.PUBLISHER%type,
      pi_language in BOOKS.LANGUAGE%type
  )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_book_create_update';
    v_params logger.tab_param;
    v_id books.id%type;
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.append_param(v_params, 'pi_title', pi_title);
    logger.append_param(v_params, 'pi_author', pi_author);
    logger.append_param(v_params, 'pi_isbn', pi_isbn);
    logger.append_param(v_params, 'pi_year', pi_year);
    logger.append_param(v_params, 'pi_genre_id', pi_genre_id);
    logger.append_param(v_params, 'pi_location_id', pi_location_id);
    logger.append_param(v_params, 'pi_score', pi_score);
    logger.append_param(v_params, 'pi_description', pi_description);
    logger.append_param(v_params, 'pi_cover', length(pi_cover));
    logger.append_param(v_params, 'pi_mime', pi_mime);
    logger.append_param(v_params, 'pi_file_name', pi_file_name);
    logger.append_param(v_params, 'pi_publisher', pi_publisher);
    logger.append_param(v_params, 'pi_language', pi_language);
    logger.log('START', v_scope, null, v_params);

    if pi_id is null then
      INSERT INTO BOOKS (title, author, isbn, year, genre_id, location_id, score, description, cover, MIME_TYPE, FILE_NAME, PUBLISHER, LANGUAGE, DATE_ADDED)
      VALUES (pi_title, pi_author, pi_isbn, pi_year, pi_genre_id, pi_location_id, pi_score, pi_description, pi_cover, pi_mime, pi_file_name, pi_publisher, pi_language, SYSDATE)
      returning id into v_id;
      pkg_history.p_history_log(pi_action => 'NEW', pi_book_id => v_id, pi_wishbook_id => null, pi_section => 'LIBRARY_BOOKS');
      logger.log('Książka '||pi_title||' została dodana.', v_scope);
    else update books
          set title=pi_title,
              author=pi_author,
              isbn=pi_isbn,
              year=pi_year,
              genre_id=pi_genre_id,
              location_id=pi_location_id,
              score=pi_score,
              description=pi_description,
              PUBLISHER=pi_publisher,
              LANGUAGE=pi_language,
              cover=nvl(pi_cover, cover),
              mime_type=nvl(pi_mime, mime_type),
              file_name=nvl(pi_file_name, file_name)
          where ID = pi_id;
          pkg_history.p_history_log(pi_action => 'UPDATE', pi_book_id => pi_id, pi_wishbook_id => null, pi_section => 'LIBRARY_BOOKS');
          logger.log('Książka '||pi_title||' została edytowana.', v_scope);
    end if;
  logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_book_create_update;




PROCEDURE p_data_export 
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_data_export';
    v_params logger.tab_param;
    l_context apex_exec.t_context; 
    l_export  apex_data_export.t_export;
  BEGIN
    logger.log('START', v_scope, null, v_params);
    l_context := apex_exec.open_query_context(
        p_location    => apex_exec.c_location_local_db,
        p_sql_query   => 
        'select b.title as Tytuł, b.author as Autor, b.isbn as ISBN, b.year as Rok_wydania, g.name as Gatunek, l.name as Lokalizacja, b.score as Ocena, b.description as Opis
        from books b
        left join book_genres g 
        on b.genre_id = g.id
        left join locations l 
        on b.location_id = l.id' 
        );

    l_export := apex_data_export.export (
                        p_context   => l_context,
                        p_format    => apex_data_export.c_format_xlsx,
                        p_file_name => 'Raport książek');

    apex_exec.close( l_context );

    apex_data_export.download( p_export => l_export );
    logger.log('Eksportowano raport', v_scope);
  EXCEPTION
    when others THEN
        logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
        raise;
        apex_exec.close( l_context );
        raise;
END p_data_export;    
  
  
  

procedure p_delete_book(
    pi_id in books.id%type)
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_delete_book';
    v_params logger.tab_param;
    v_row_count NUMBER;
  
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.log('START', v_scope, null, v_params);

    SELECT COUNT(*)
    INTO v_row_count
    FROM history
    WHERE book_id = pi_id;
    
    --usuwamy z bazy w przypadku kiedy książka była jedynie dodana, nie było na niej więcej akcji. Jeśli były, wtedy zostawiamy ją w bazie i zmieniamy tylko flagę DELETED 
    if v_row_count <= 1 THEN    
      DELETE FROM history
      WHERE book_id=pi_id;
      DELETE FROM books 
      WHERE ID=pi_id;
      logger.log('Książka usunięta.', v_scope);
      else
      select COUNT(*)
      into v_row_count
      from BOOK_LENDING
      where book_id = pi_id
      and end_date is NULL;
        if v_row_count = 0 then
          update BOOKS
          set DELETED ='Y'
          where ID = pi_id;
          pkg_history.p_history_log(pi_action => 'DELETE', pi_book_id => pi_id, pi_wishbook_id => null, pi_section => 'LIBRARY_BOOKS');
          logger.log('Książka usunięta.', v_scope);
          else 
          raise_application_error(-20001, 'Nie można usunąć wypożyczonej książki.');
      end if;
      
    end if;

    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_delete_book;
  



procedure p_restore_book(
    pi_id in books.id%type)
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_restore_book';
    v_params logger.tab_param;
    v_deleted_count NUMBER;
  
  begin
    logger.append_param(v_params, 'pi_id', pi_id);
    logger.log('START', v_scope, null, v_params);
    select count(*)
    into v_deleted_count
    from BOOKS
    where id = pi_id AND DELETED = 'Y';
  
    if v_deleted_count = 1 THEN
      update BOOKS
      set DELETED ='N'
      where id = pi_id;
  
      pkg_history.p_history_log(pi_action => 'RESTORE', pi_book_id => pi_id, pi_wishbook_id => null, pi_section => 'LIBRARY_BOOKS');
      logger.log('Książka przywrócona', v_scope);
    else 
      RAISE_APPLICATION_ERROR(-20006, 'Książka nie była usunięta.');
    end if;
  
    logger.log('END', v_scope);
    
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_restore_book;





procedure p_openlibrary_api(
    pi_isbn in books.isbn%type)
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_openlibrary_api';
    v_params logger.tab_param;
    v_url VARCHAR2(4000);
    v_cover_url VARCHAR2(4000);
    v_desc_url VARCHAR2(4000);
    v_desc_id varchar2(200);
    v_response CLOB;
    v_response_d CLOB;
    v_cover BLOB;
    j apex_json.t_values;
    d apex_json.t_values;
    v_id varchar2(200);
    v_members apex_t_varchar2;
    v_members_d apex_t_varchar2;
    v_year varchar2(200);
    v_publisher varchar2(200);
    v_title varchar2(200);
    v_author varchar2(200);
    v_lang varchar2(200);
    v_desc VARCHAR2(4000);
  begin
    logger.append_param(v_params, 'pi_isbn', pi_isbn);
    logger.log('START', v_scope, null, v_params);
    v_url := 'https://openlibrary.org/api/volumes/brief/isbn/'||pi_isbn||'.json';
    v_cover_url := 'https://covers.openlibrary.org/b/isbn/'||pi_isbn||'-L.jpg'; 
    v_response := APEX_WEB_SERVICE.MAKE_REST_REQUEST(
        p_url => v_url,
        p_http_method => 'GET'
    );
    v_cover := APEX_WEB_SERVICE.MAKE_REST_REQUEST_B(
        p_url => v_cover_url,
        p_http_method => 'GET'
    );
    apex_json.parse(j, v_response);   
    v_members := apex_json.GET_MEMBERS (
        p_values => j,
        p_path => 'records'
    );

    IF v_members IS NULL OR v_members.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Książka o podanym ISBN nie jest dostępna w Open Library.');
    END IF;

    v_id := v_members(1);

    v_desc_id := APEX_JSON.GET_VARCHAR2 (
        p_path => 'records.%0.details.details.works[1].key',
        p0 => v_id,
        p_values => j
    );
    v_desc_url := 'https://openlibrary.org'||v_desc_id||'.json';
    v_response_d := APEX_WEB_SERVICE.MAKE_REST_REQUEST(
        p_url => v_desc_url,
        p_http_method => 'GET'
    );
    v_members_d := apex_json.GET_MEMBERS (
        p_values => d,
        p_path => ''
    );
    apex_json.parse(d, v_response_d);

    if APEX_JSON.DOES_EXIST(p_path => 'description.value', p_values => d) then
        v_desc := APEX_JSON.GET_VARCHAR2 (
            p_path => 'description.value',
            p_values => d
        );
    elsif APEX_JSON.DOES_EXIST(p_path => 'description', p_values => d) then
        v_desc := APEX_JSON.GET_VARCHAR2 (
            p_path => 'description',
            p_values => d
        );
    else
        v_desc := null;
    end if;

    v_year := APEX_JSON.GET_VARCHAR2 (
        p_path => 'records.%0.data.publish_date',
        p0 => v_id,
        p_values => j
    );
    v_title := APEX_JSON.GET_VARCHAR2 (
      p_path => 'records.%0.data.title',
      p0 => v_id,
      p_values => j
    );
    v_publisher := APEX_JSON.GET_VARCHAR2 (
        p_path => 'records.%0.data.publishers[1].name',
        p0 => v_id,
        p_values => j
    );
    v_author := APEX_JSON.GET_VARCHAR2 (
        p_path => 'records.%0.data.authors[1].name',
        p0 => v_id,
        p_values => j
    );
    v_lang := APEX_JSON.GET_VARCHAR2 (
      p_path => 'records.%0.details.details.languages[1].key',
      p0 => v_id,
      p_values => j
    );
    IF v_year IS NOT NULL THEN
      update books
        set YEAR=SUBSTR(v_year,-4)
      where ISBN=pi_isbn;
    END IF;
    IF v_desc IS NOT NULL THEN
      update books
        set DESCRIPTION=v_desc
      where ISBN=pi_isbn;
    END IF;
    IF v_title IS NOT NULL THEN
      update books
        set TITLE=v_title
      where ISBN=pi_isbn;
    END IF;
    IF v_author IS NOT NULL THEN
      update books
        set AUTHOR=v_author
      where ISBN=pi_isbn;
    END IF;
    IF v_publisher IS NOT NULL THEN
      update books
        set PUBLISHER=v_publisher
      where ISBN=pi_isbn;
    END IF;
    IF v_lang = '/languages/pol' then
      update books
        set LANGUAGE='polski'
      where ISBN=pi_isbn;
      elsif v_lang = '/languages/eng' then
        update books
        set LANGUAGE='angielski'
      where ISBN=pi_isbn;
      else update books
        set LANGUAGE=v_lang
      where ISBN=pi_isbn;
    END IF;
    IF v_cover IS NOT NULL THEN
      update books
        set COVER=v_cover, MIME_TYPE='image/jpeg', FILE_NAME = REPLACE(v_title, ' ', '_') || '.jpg'
      where ISBN=pi_isbn;
    END IF;
  logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise; 
end p_openlibrary_api;




procedure p_openlibrary_api_get_data(
      pi_isbn in books.isbn%type,
      po_year out books.year%type,
      po_title out books.title%type,
      po_author out books.author%type,
      po_publisher out books.publisher%type,
      po_language out books.language%type,
      po_description out books.description%type
  )
  as
      v_scope logger_logs.scope%type := gc_scope_prefix || 'p_openlibrary_api_get_data';
      v_params logger.tab_param;
      v_url VARCHAR2(4000);
      v_cover_url VARCHAR2(4000);
      v_desc_url VARCHAR2(4000);
      v_desc_id varchar2(200);
      v_response CLOB;
      v_response_d CLOB;
      v_cover BLOB;
      j apex_json.t_values;
      d apex_json.t_values;
      v_id varchar2(200);
      v_members apex_t_varchar2;
      v_members_d apex_t_varchar2;
      v_number_of_authors NUMBER;
      v_author books.author%type;
  begin
      logger.append_param(v_params, 'pi_isbn', pi_isbn);
      logger.log('START', v_scope, null, v_params);
      v_url := 'https://openlibrary.org/api/volumes/brief/isbn/'||pi_isbn||'.json';
      v_cover_url := 'https://covers.openlibrary.org/b/isbn/'||pi_isbn||'-L.jpg'; 

      v_response := APEX_WEB_SERVICE.MAKE_REST_REQUEST(
          p_url => v_url,
          p_http_method => 'GET'
      );

      v_cover := APEX_WEB_SERVICE.MAKE_REST_REQUEST_B(
          p_url => v_cover_url,
          p_http_method => 'GET'
      );
      apex_json.parse(j, v_response);

      v_members := apex_json.GET_MEMBERS (
          p_values => j,
          p_path => 'records'
      );

      IF v_members IS NULL OR v_members.COUNT = 0 THEN
          RAISE_APPLICATION_ERROR(-20001, 'Książka o podanym ISBN nie jest dostępna w Open Library.');
      END IF;

      v_id := v_members(1);

      v_desc_id := APEX_JSON.GET_VARCHAR2 (
        p_path => 'records.%0.details.details.works[1].key',
        p0 => v_id,
        p_values => j
      );
      v_desc_url := 'https://openlibrary.org'||v_desc_id||'.json';
      v_response_d := APEX_WEB_SERVICE.MAKE_REST_REQUEST(
        p_url => v_desc_url,
        p_http_method => 'GET'
      );
      v_members_d := apex_json.GET_MEMBERS (
        p_values => d,
        p_path => ''
      );
      apex_json.parse(d, v_response_d);

      if APEX_JSON.DOES_EXIST(p_path => 'description.value', p_values => d) then
          po_description := APEX_JSON.GET_VARCHAR2 (
              p_path => 'description.value',
              p_values => d
          );
      elsif APEX_JSON.DOES_EXIST(p_path => 'description', p_values => d) then
          po_description := APEX_JSON.GET_VARCHAR2 (
              p_path => 'description',
              p_values => d
          );
      else
          po_description := null;
      end if;

      po_year := TO_NUMBER(SUBSTR(APEX_JSON.GET_VARCHAR2 (
          p_path => 'records.%0.data.publish_date',
          p0 => v_id,
          p_values => j), -4)
      );

      if APEX_JSON.DOES_EXIST(        
        p_path => 'records.%0.data.subtitle',
        p0 => v_id,
        p_values => j)
      then 
        po_title := APEX_JSON.GET_VARCHAR2 (
          p_path => 'records.%0.data.title',
          p0 => v_id,
          p_values => j
        )||': '|| APEX_JSON.GET_VARCHAR2 (
          p_path => 'records.%0.data.subtitle',
          p0 => v_id,
          p_values => j
        );
      else 
        po_title := APEX_JSON.GET_VARCHAR2 (
          p_path => 'records.%0.data.title',
          p0 => v_id,
          p_values => j
          );
      end if;

      po_publisher := APEX_JSON.GET_VARCHAR2 (
          p_path => 'records.%0.data.publishers[1].name',
          p0 => v_id,
          p_values => j
      );
      v_number_of_authors := APEX_JSON.GET_COUNT(p_path => 'records.%0.data.authors',
          p0 => v_id,
          p_values => j
      );

      if v_number_of_authors <= 1 then
      po_author := APEX_JSON.GET_VARCHAR2 (
          p_path => 'records.%0.data.authors[1].name',
          p0 => v_id,
          p_values => j
      );
      else v_author := APEX_JSON.GET_VARCHAR2 (
          p_path => 'records.%0.data.authors[1].name',
          p0 => v_id,
          p_values => j);
      
        for i in 1..v_number_of_authors-1 loop
            v_author := v_author||', '||APEX_JSON.GET_VARCHAR2 (
            p_path => 'records.%0.data.authors[%1].name',
            p0 => v_id,
            p1 => i+1,
            p_values => j);
        end loop;
        po_author := v_author;
      END IF;

      po_language := APEX_JSON.GET_VARCHAR2 (
        p_path => 'records.%0.details.details.languages[1].key',
        p0 => v_id,
        p_values => j
      );

      IF po_language = '/languages/pol' THEN
          po_language := 'polski';
      ELSIF po_language = '/languages/eng' THEN
          po_language := 'angielski';
      END IF;

      apex_collection.create_or_truncate_collection('TEMP_COVER');
      APEX_COLLECTION.ADD_MEMBER(p_collection_name => 'TEMP_COVER', p_blob001 => v_cover);

      logger.log('END', v_scope);
  exception
      when others then
          logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
          raise;
end p_openlibrary_api_get_data;
  


procedure p_narodowa_api_get_data(
      pi_isbn in books.isbn%type,
      po_year out books.year%type,
      po_title out books.title%type,
      po_author out books.author%type,
      po_publisher out books.publisher%type,
      po_language out books.language%type,
      po_description out books.description%type
  )
  as
    v_scope logger_logs.scope%type := gc_scope_prefix || 'p_narodowa_api_get_data';
    v_params logger.tab_param;
      v_url VARCHAR2(4000);
      v_response CLOB;
      j apex_json.t_values;
      v_members apex_t_varchar2;
  begin
    logger.append_param(v_params, 'pi_isbn', pi_isbn);
    logger.log('START', v_scope, null, v_params);

    v_url := 'https://data.bn.org.pl//api/institutions/bibs.json?isbnIssn='||pi_isbn;
    v_response := APEX_WEB_SERVICE.MAKE_REST_REQUEST(
          p_url => v_url,
          p_http_method => 'GET'
    );
    apex_json.parse(j, v_response);

    v_members := apex_json.GET_MEMBERS (
          p_values => j,
          p_path => 'bibs[1]'
      );

    IF v_members IS NULL OR v_members.COUNT = 0 THEN
          RAISE_APPLICATION_ERROR(-20001, 'Książka o podanym ISBN nie jest dostępna w Bibliotece Narodowej.');
    END IF;

    po_year := APEX_JSON.GET_VARCHAR2 (
        p_path => 'bibs[1].publicationYear',
        p_values => j
      );
    po_title := APEX_JSON.GET_VARCHAR2 (
        p_path => 'bibs[1].title',
        p_values => j
      );
    po_publisher := APEX_JSON.GET_VARCHAR2 (
        p_path => 'bibs[1].publisher',
        p_values => j
      );
    po_author := APEX_JSON.GET_VARCHAR2 (
        p_path => 'bibs[1].author',
        p_values => j
      );
    po_language := APEX_JSON.GET_VARCHAR2 (
        p_path => 'bibs[1].language',
        p_values => j
      );
    po_description := APEX_JSON.GET_VARCHAR2 (
        p_path => 'bibs[1].genre',
        p_values => j
      );
    logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_narodowa_api_get_data;

  

end pkg_books;
/