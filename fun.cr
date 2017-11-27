require "sentry-run"

process = Sentry.config(
  process_name: "App",
  build_command: "crystal",
  run_command: "./.bin/run",
  files: [
    "app.cr", "run.cr",
    "app/**/*.cr", "app/**/*.ecr",
    "config/**/*.cr", "config/**/*.ecr",
  ],
  build_args: ["build", "run.cr", "-o", ".bin/run"],
  run_args: ["-p", "9000"]
)

Sentry.run(process) do
end
