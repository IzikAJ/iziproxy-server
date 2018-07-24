module Active
  module AccessibleAttributes
    macro accesible(*keys)
      def fetch_param(params : HTTP::Params, key : String)
        params[key]
      end

      def self.from_params(params : HTTP::Params)
        form = self.new
        form.fetch_all(params)
        form
      end

      def [](key : String)
        {% for key in keys %}
          return self.{{key}} if "{{key}}" == key
        {% end %}
      end

      def []=(key : String, value)
        {% for key in keys %}
          return self.{{key}} = value if "{{key}}" == key
        {% end %}
      end

      def fetch_all(params : HTTP::Params)
        {% for key in keys %}
          self.{{key}} = params["{{key}}"]
        {% end %}
      end
    end
  end
end
