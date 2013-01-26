-module(kellin_irc).
-author("Alyx Wolcott <contact@alyxw.me>").
-export([connect/2, loop/1]).

connect(Host, Port) ->
	{ok, Sock} = gen_tcp:connect(Host, Port, [{packet, line}]),
%	gen_tcp:send(Sock, "USER " ++ kellin_conf:nickname ++ )
	send_irc(Sock, "USER " ++ kellin_conf:user ++ " * * " ++ 
		kellin_conf:whois),
	send_irc(Sock, "NICK " ++ kellin_conf:nickname),
	loop(Sock).

loop(Sock) ->
	receive
			{tcp, Sock, Data} ->
				parse_irc_string(Sock, string:tokens(Data, ": ")),
				loop(Sock);

			{np, User, Data} ->
				handle_now_playing(User, Data),
				loop(Sock);
			quit ->
				io:format("[~w] Received quit message.~n"),
				gen_tcp:close(Sock),
				exit(stopped)
	end.

handle_now_playing(User, Data) ->
	sned_irc("PRIVMSG #alyx :" ++ User ++ " is now playing: "
		++ Data).

send_irc(Sock, Data) ->
	gen_tcp:send(Sock, Data ++ "\r\n").
