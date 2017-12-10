module Active
  module Validation
    abstract def valid?

    property errors = {} of String => String | Nil

    macro validate(key, *validators)
      {% for validator in validators %}
        unless {{validator}}?("{{key}}")
          errors["{{key}}"] = error_message("{{validator}}")
          return false
        end
      {% end %}
    end

    macro validate(key, **validators)
      {% for validator, fn in validators %}
        unless {{validator}}?("{{key}}")
          {{fn}}.call("{{validator}}")
          return false
        end
      {% end %}
    end

    def error_message(key)
      case key
      when "email"
        "invalid"
      else
        key
      end
    end

    def add_error(key : String, msg : String)
      return if errors[key]?
      errors[key] = msg
    end

    def add_error(key : Symbol, msg : String)
      add_error key.to_s, msg
    end

    def invalid?
      !valid?
    end
  end
end
