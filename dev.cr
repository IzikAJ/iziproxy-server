require "sentry-run"

process = Sentry.config(
  process_name: "App",
  build_command: "crystal",
  run_command: "./.bin/app",
  files: [
    "app.cr",
    "app/**/*.cr", "app/**/*.ecr",
    "app/**/*.slang", "app/**/*.slim",
    "config/**/*.cr", "config/**/*.ecr",
  ],
  build_args: ["build", "app.cr", "-o", ".bin/app"],
  run_args: ["-p", "9000"])

Sentry.run(process) do end
