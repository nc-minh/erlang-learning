-module(client).

-export([connect/1, send_message/2]).

connect(Username) ->
    {ok, Socket} = gen_tcp:connect("localhost", 5678, [binary, {packet, 0}]),
    ok = gen_tcp:send(Socket, Username),
    {ok, Socket}.

send_message(Socket, Message) ->
    ok = gen_tcp:send(Socket, Message).
