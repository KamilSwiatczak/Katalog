
create or replace package body pkg_games
as

  --==== Scope loggera ====--
  gc_scope_prefix constant varchar2(31) := lower('pkg_games') || '.';



procedure p_game_create_update(
      pi_id in games.id%type,
      pi_title in games.title%type,
      pi_description IN games.description%TYPE,
      pi_genre IN games.genre%TYPE,
      pi_score IN games.score%TYPE,
      pi_box IN games.box%TYPE,
      pi_steam IN games.steam%TYPE,
      pi_gog IN games.gog%TYPE,
      pi_epic IN games.epic%TYPE,
      pi_bnet IN games.bnet%TYPE,
      pi_humble IN games.humble%TYPE,
      pi_ea IN games.ea%TYPE,
      pi_uplay IN games.uplay%TYPE,
      pi_comment IN games.the_comment%TYPE,
      pi_developer IN games.developer%TYPE,
      pi_location_id IN games.location_id%TYPE,
      pi_cover_link IN games.cover_link%TYPE,
      pi_cover IN games.cover%TYPE,
      pi_mime_type IN games.mime_type%TYPE,
      pi_file_name IN games.file_name%TYPE,
      pi_release_date IN games.release_date%TYPE)
as
  v_scope logger_logs.scope%type := gc_scope_prefix || 'p_game_create_update';
  v_params logger.tab_param;
  v_id games.id%type;
begin
  logger.append_param(v_params, 'pi_id', pi_id);
  logger.append_param(v_params, 'pi_title', pi_title);
  logger.append_param(v_params, 'pi_description', pi_description);
  logger.append_param(v_params, 'pi_genre', pi_genre);
  logger.append_param(v_params, 'pi_score', pi_score);
  logger.append_param(v_params, 'pi_box', pi_box);
  logger.append_param(v_params, 'pi_steam', pi_steam);
  logger.append_param(v_params, 'pi_gog', pi_gog);
  logger.append_param(v_params, 'pi_epic', pi_epic);
  logger.append_param(v_params, 'pi_bnet', pi_bnet);
  logger.append_param(v_params, 'pi_humble', pi_humble);
  logger.append_param(v_params, 'pi_ea', pi_ea);
  logger.append_param(v_params, 'pi_uplay', pi_uplay);
  logger.append_param(v_params, 'pi_comment', pi_comment);
  logger.append_param(v_params, 'pi_developer', pi_developer);
  logger.append_param(v_params, 'pi_location_id', pi_location_id);
  logger.append_param(v_params, 'pi_cover_link', pi_cover_link);
  logger.append_param(v_params, 'pi_cover', length(pi_cover));
  logger.append_param(v_params, 'pi_mime_type', pi_mime_type);
  logger.append_param(v_params, 'pi_file_name', pi_file_name);
  logger.append_param(v_params, 'pi_release_date', pi_release_date);

  logger.log('START', v_scope, null, v_params);

    if pi_id is null then 
      INSERT INTO GAMES (TITLE, DESCRIPTION, GENRE, SCORE, BOX, STEAM, GOG, EPIC, BNET, HUMBLE, EA, UPLAY, THE_COMMENT, DEVELOPER, LOCATION_ID, COVER, COVER_LINK, MIME_TYPE, FILE_NAME, RELEASE_DATE, DATE_ADDED)
      VALUES (pi_title, pi_description, pi_genre, pi_score, pi_box, pi_steam, pi_gog, pi_epic, pi_bnet, pi_humble, pi_ea, pi_uplay, pi_comment, pi_developer, pi_location_id, pi_cover, pi_cover_link, pi_mime_type, pi_file_name, pi_release_date, SYSDATE)
      returning id into v_id;
      logger.log('Gra '||pi_title||' została dodana.', v_scope);
    else update GAMES
      set TITLE=pi_title,
        DESCRIPTION=pi_description, 
        GENRE=pi_genre, 
        SCORE=pi_score, 
        BOX=pi_box, 
        STEAM=pi_steam, 
        GOG=pi_gog, 
        EPIC=pi_epic, 
        BNET=pi_bnet, 
        HUMBLE=pi_humble, 
        EA=pi_ea, 
        UPLAY=pi_uplay, 
        THE_COMMENT=pi_comment, 
        DEVELOPER=pi_developer, 
        LOCATION_ID=pi_location_id, 
        COVER=pi_cover, 
        COVER_LINK=pi_cover_link, 
        MIME_TYPE=pi_mime_type, 
        FILE_NAME=pi_file_name, 
        RELEASE_DATE=pi_release_date
      where ID = pi_id;
      logger.log('Gra '||pi_title||' została edytowana.', v_scope);
    end if;
  logger.log('END', v_scope);
  exception
    when others then
      logger.log_error('Nieznany błąd: '||SQLERRM, v_scope, null, v_params);
      raise;
end p_game_create_update;

  
end pkg_games;
/