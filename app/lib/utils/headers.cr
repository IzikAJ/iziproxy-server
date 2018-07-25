require "json"

module App
  module Utils
    module Headers
      extend self

      def build_json(builder : JSON::Builder, headers : HTTP::Headers)
        builder.object do
          headers.each do |name, values|
            builder.field name do
              builder.array do
                values.each do |value|
                  builder.string value
                end
              end
            end
          end
        end
      end

      def parse_json(object : JSON::Any | Nil)
        headers = HTTP::Headers.new
        return headers if object.nil?

        object.as_h.each do |key, values|
          values.as_a.each do |value|
            headers.add(key, value.as_s)
          end
        end

        headers
      end
    end
  end
end
