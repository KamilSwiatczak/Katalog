create or replace package pkg_games
as


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
      pi_release_date IN games.release_date%TYPE
);

procedure p_mobygames_api_get_data(
      pio_title in games.title%type,
      po_description IN games.description%TYPE,
      po_genre IN games.genre%TYPE,
      po_score IN games.score%TYPE,
      po_year IN games.release_date%TYPE
);

end pkg_games;
/