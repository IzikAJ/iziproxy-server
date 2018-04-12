require "../../controllers/application_controller"

class HTTP::Server::Context
  property controller_name : String?
  property controller : ApplicationController?
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
        if (controller = \{{ ctrl_name.id }}.new(env)) && \{{action_name}}
          env.controller = controller

          if controller.responds_to?(:action_\{{action_name.id}})
            controller.action_\{{action_name.id}}
          elsif controller.responds_to?(:\{{action_name.id}})
            controller.\{{action_name.id}}
          else
            "
              <hr/>
              <center>
                <h2>Router error</h3>
                <p>
                  ACTION
                  <b>'\{{action_name.id}}'</b>
                  IN CONTROLLER
                  <b>'\{{ctrl_name.id}}'</b>
                  NOT DEFINED!
                </p>
              </center>
              <hr/>
            "
          end
        end
      end
    end
  {% end %}
end
