require "../api_controller"
require "../../../app/queries/request_tokens_query"

module Api
  module Accounts
    class TokensController < ApiController
      def index
        if (session = context.request.session) &&
           (user = session.user)
          data = RequestTokensQuery.new(user).list.map do |token|
            TokenSerializer.new(token).as_json
          end
          respond data
        else
          fail!
        end
      end

      def destroy
        if (session = context.request.session) &&
           (user = session.user) &&
           (token_id = params["token_id"]?)
          token = RequestTokensQuery.new(user).find(token_id.to_i64)
          if token
            token.destroy
            # serialize_token(token).to_json
            respond TokenSerializer.new(token)
          else
            fail! 404, "token not found"
          end
        else
          fail! 422, "some error occured"
        end
      end

      def create
        token = AuthToken.new
        if (session = context.request.session) &&
           (user = session.user) &&
           (token.user_id = user.id.not_nil!.to_i64) &&
           token.save
          # serialize_token(token).to_json
          respond TokenSerializer.new(token)
        else
          status_code! 422
          respond({errors: "token generation error"}.to_h)
        end
      end

      private def serialize_token(token : AuthToken)
        {
          id:         token.id,
          token:      token.token,
          expired_at: token.expired_at,
        }
      end
    end
  end
end
