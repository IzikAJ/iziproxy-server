require "crinja"
require "../helpers/*"

module App
  module Views
    class Base
      @env = Crinja::Environment.new
      @params = {} of String => String | Array(String)

      def initialize(@app : App::Server, @context : HTTP::Server::Context)
      end

      protected def render(filename : String, status : Int32 = 200)
        # @@env ||= Crinja::Environment.new
        # @@params ||= {} of String => String | Array(String)
        template = "N/A"
        if env = @env
          env.loader = Crinja::Loader::FileSystemLoader.new("app/views/")
          template = env.get_template(filename)

          @context.response.status_code = status || 200
          @context.response.content_type = "text/html"

          @context.response.print template.render(@params)
        end
      end
    end
  end
end

require "./welcome/controller"
