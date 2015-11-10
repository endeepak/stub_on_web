# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :stub_on_web, StubOnWeb.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "diDAA0wpHWzPjBtAZi5wb0fEz6rheLDuohRKxLSHxxucHg0ankmtk50Z6/DY97SX",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: StubOnWeb.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Only recent max_stub_url_calls will be retained in system
config :stub_on_web, :max_stub_url_calls, 20

# Ignore request headers like the ones added by Heroku
config :stub_on_web, :ignore_request_headers, 
	  ["X-Forwarded-For", "X-Forwarded-Proto", "X-Forwarded-Port", "X-Request-Start", "X-Request-Id", "Via", "Connect-Time", "Total-Route-Time"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"



