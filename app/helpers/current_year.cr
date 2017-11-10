require "crinja"

Crinja.function(:current_year) do
  Time.now.year
end
