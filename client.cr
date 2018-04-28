# require "faraday"
require "./proxy_client/*"
require "optarg"
require "yaml"

# require "dotenv"
# Dotenv.load
ProxyClient::Configs.load!
ProxyClient::Options.load!
