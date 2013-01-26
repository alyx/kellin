-module(kellin_irc).
-author("Alyx Wolcott <contact@alyxw.me>").
-export([connect/2, loop/1]).

connect(Host, Port) ->
	{ok, Sock} = gen_tcp:connect(Host, Port, [{packet, line}]),
	send_irc(Sock, "USER " ++ kellin_conf:user ++ " * * " ++ kellin_conf:whois),
	send_irc(Sock, "NICK " ++ kellin_conf:nickname),
	loop(Sock).

loop(Sock) ->
	receive
			{tcp, Sock, Data} ->
				parse_irc_string(Sock, string:tokens(Data, ": ")),
				loop(Sock);

			{np, User, Data} ->
				handle_now_playing(Sock, User, Data),
				loop(Sock);
			quit ->
				gen_tcp:close(Sock),
				exit(stopped)
	end.

handle_now_playing(Sock, User, Data) ->
	send_irc(Sock, "PRIVMSG #alyx :" ++ User ++ " is now playing: "
		++ Data).

send_irc(Sock, Data) ->
	gen_tcp:send(Sock, Data ++ "\r\n").

parse_irc_string(Sock, [_, "376"|_]) ->
	send_irc(Sock, "JOIN #alyx").

parse_irc_string(Sock, ["PING"|Rest]) ->
	send_irc(Sock, "PONG " ++ Rest).

parse_irc_string(_, _) ->
	0.
