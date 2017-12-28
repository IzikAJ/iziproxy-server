require "./pretty_routes"

module ApiRoutes
  {% for method in ["get", "post", "put", "patch"] %}
    macro {{method.id}}(path, resolver)
      {{method.id}} "/api/\{{path.id}}.json" do |env|
        \{% ctrl_params = ("api/" + resolver).split('#') %}
        \{% ctrl_name = "#{ctrl_params[0].id}_controller".split("/").map(&.camelcase).join("::") %}
        \{% action_name = ctrl_params[1] %}
        env.controller_name = \{{ ctrl_name }}
        env.action_name = \{{action_name}}
        \{{ ctrl_name.id }}.new(env).\{{action_name.id}}
      end
    end
  {% end %}
end
