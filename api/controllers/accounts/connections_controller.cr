require "../api_controller"
require "../../../app/queries/connections_query"

module Api
  module Accounts
    class ConnectionsController < ApiController
      def index
        if (session = context.request.session) &&
           (user = session.user)
          data = ConnectionsQuery.new(user).list.map do |t|
            ConnectionSerializer.new(t).as_json
          end
          respond data
        else
          fail!
        end
      end
    end
  end
end
