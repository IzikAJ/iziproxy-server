module Active
  module AccessibleAttributes
    macro accesible(*keys)
      def fetch_param(params : Kemal::ParamParser, key : String)
        params.body.fetch(key, nil)
      end

      def self.from_params(params : Kemal::ParamParser)
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

      def fetch_all(params : Kemal::ParamParser)
        {% for key in keys %}
          self.{{key}} = fetch_param(params, "{{key}}")
        {% end %}
      end
    end
  end
end
