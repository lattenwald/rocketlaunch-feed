defmodule RocketlaunchFeed.Feed do
  @url "https://fdo.rocketlaunch.live/json/launches/next/5"

  def fetch do
    with {:ok, %{status_code: 200, body: body}} <- HTTPoison.get(@url),
         {:ok, %{"result" => launches}} <- Poison.decode(body) do
      items =
        launches
        |> Enum.map(&launch_to_xml_structure/1)
        |> Enum.sort()
        |> Enum.reverse()
        |> Enum.map(fn {_, xml} -> xml end)

      feed =
        {:rss, %{version: "2.0"},
         [
           {:channel, nil,
            [
              {:title, nil, "RocketLaunch feed"},
              {:description, nil, "Feed generated from JSON API"},
              {:link, nil, "https://www.rocketlaunch.live/"}
            ] ++ items}
         ]}

      feed |> XmlBuilder.document() |> XmlBuilder.generate()
    else
      {:ok, %{status_code: 200, body: body}} ->
        {:content_error, body}

      {:ok, %{status_code: error_code}} ->
        {:error, {:http_error, error_code}}

      other = {:error, _} ->
        other
    end
  end

  def launch_to_xml_structure(json) do
    %{
      "slug" => slug,
      "sort_date" => sort_date,
      "provider" => %{"name" => provider_name},
      "vehicle" => %{"name" => vehicle_name},
      "pad" => %{
        "name" => pad_name,
        "location" => %{"country" => pad_location_country, "name" => pad_location_name}
      },
      "launch_description" => launch_description,
      "missions" => missions,
      "tags" => tags,
      "t0" => launch_t0,
      "est_date" => %{"year" => year, "month" => month, "day" => day},
      "date_str" => date_str,
      "suborbital" => suborbital
    } = json

    launch_time =
      case launch_t0 do
        nil ->
          with t <- Timex.to_date({year, month, day}),
               {:ok, formatted} <- Timex.format(t, "%F", :strftime) do
            formatted
          else
            _ -> date_str
          end

        _ ->
          with {:ok, parsed_t0} <- Timex.parse(launch_t0, "%FT%RZ", :strftime),
               with_timezone <- Timex.to_datetime(parsed_t0, "UTC"),
               {:ok, formatted} <- Timex.format(with_timezone, "%F %R %Z", :strftime) do
            formatted
          end
      end

    title =
      ~s(#{if suborbital, do: "Suborbital ", else: ""}#{provider_name} - #{vehicle_name} - #{pad_name}, #{pad_location_name}, #{pad_location_country} - #{launch_time})

    missions_text =
      missions
      |> Enum.map(fn %{"name" => mission_name, "description" => mission_description} ->
        ~s("#{mission_name}: #{mission_description}")
      end)
      |> Enum.join("\n")

    text = ~s(#{launch_description}\n\n#{missions_text})

    link = ~s(https://rocketlaunch.live/launch/#{slug})

    categories = tags |> Enum.map(fn %{"text" => tag} -> {:category, nil, tag} end)

    {sort, _} = Integer.parse(sort_date)

    {sort,
     {:item, nil,
      [
        {:title, nil, title},
        {:link, nil, link},
        {:description, nil, text}
      ] ++ categories}}
  end
end
