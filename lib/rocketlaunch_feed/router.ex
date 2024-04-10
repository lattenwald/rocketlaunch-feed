defmodule RocketlaunchFeed.Router do
  require Logger

  use Plug.Router

  plug(Plug.Parsers, parsers: [:urlencoded, :multipart])
  plug(:match)
  plug(:dispatch)

  get "/hello" do
    send_resp(conn, 200, "world")
  end

  get "/feed.rss" do
    Logger.debug(fn -> inspect(conn.body_params) end)

    feed = RocketlaunchFeed.Feed.fetch

    conn
    |> put_resp_header("Content-Type", "application/rss+xml")
    |> send_resp(200, feed)
  end

  match _ do
    send_resp(conn, 404, "oops")
  end
end
