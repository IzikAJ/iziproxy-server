require "sentry"

# app_ws.cr
sentry_ws = Sentry::ProcessRunner.new(
  # process_name: "AppWS",
  display_name: "AppWS",
  build_command: "crystal build app_ws.cr -o bin/app_ws",
  run_command: "./bin/app_ws",
  run_args: ["-p", "9112"],
  files: [
    "app_ws.cr",
    "app/**/*.cr",
    "config/**/*.cr",
  ]
)

# app.cr
sentry_app = Sentry::ProcessRunner.new(
  # process_name: "App MAIN",
  display_name: "App MAIN",
  build_command: "crystal build app.cr -o bin/app",
  run_command: "./bin/app",
  run_args: ["-p", "9111"],
  files: [
    "app.cr",
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
