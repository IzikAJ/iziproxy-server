require "sentry"

# app_ws.cr
sentry_ws = Sentry::ProcessRunner.new(
  display_name: "App Proxy",
  build_command: "crystal build app_proxy.cr -o bin/app_proxy",
  run_command: "./bin/app_proxy",
  # run_args: [],
  files: [
    "app_proxy.cr",
    "app/**/*.cr",
    "config/**/*.cr",
  ]
)

# app.cr
sentry_app = Sentry::ProcessRunner.new(
  display_name: "App Server",
  build_command: "crystal build app_server.cr -o bin/app_server",
  run_command: "./bin/app_server",
  # run_args: [],
  files: [
    "app_server.cr",
    "api/**/*.cr", "api/**/*.ecr",
    "app/**/*.cr", "app/**/*.ecr",
    "app/**/*.slang", "app/**/*.slim",
    "config/**/*.cr", "config/**/*.ecr",
  ]
)

spawn do
  sentry_ws.run
end
sentry_app.run
sentry_ws.kill
