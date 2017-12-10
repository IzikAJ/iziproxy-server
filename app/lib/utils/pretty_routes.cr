class HTTP::Server::Context
  property controller_name : String?
  property action_name : String?
end

module PrettyRoutes
  {% for method in ["get", "post", "put", "patch"] %}
    macro {{method.id}}(path, resolver)
      {{method.id}} \{{path}} do |env|
        \{% ctrl_params = resolver.split('#') %}
        \{% ctrl_name = "#{ctrl_params[0].id}_controller".split("/").map(&.camelcase).join("::") %}
        \{% action_name = ctrl_params[1] %}
        env.controller_name = \{{ ctrl_name }}
        env.action_name = \{{action_name}}
        \{{ ctrl_name.id }}.new(env).\{{action_name.id}}
      end
    end
  {% end %}
end
