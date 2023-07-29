-module(server).

-export([start/0]).

-define(PORT, 5678).

start() ->
    {ok, ListenSock} = gen_tcp:listen(?PORT, [binary, {packet, 0}, {active, false}]),
    spawn(fun() -> acceptor_loop(ListenSock, dict:new()) end),
    ok.

acceptor_loop(ListenSock, Users) ->
    {ok, ClientSock} = gen_tcp:accept(ListenSock),
    {ok, Username} = gen_tcp:recv(ClientSock, 0),
    spawn(fun() -> client_handler_loop(ClientSock, Username, Users) end),
    acceptor_loop(ListenSock, dict:store(Username, ClientSock, Users)).

client_handler_loop(ClientSock, Username, Users) ->
    receive
        {send_message, ToUser, Message} ->
            ToSock = dict:fetch(ToUser, Users),
            gen_tcp:send(ToSock, Message),
            client_handler_loop(ClientSock, Username, Users);
        {tcp_closed, ClientSock} ->
            io:format("~s disconnected~n", [Username])
    end.
