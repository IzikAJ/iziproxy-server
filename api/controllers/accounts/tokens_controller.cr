require "../api_controller"
require "../../forms/profile_form"

module Api
  module Accounts
    class TokensController < ApiController
      def index
        if (session = context.request.session) &&
           (user = session.user)
          profile_json user
          # puts AuthToken.all
          tokens = AuthToken.all(
            "WHERE user_id = ?",
            [user.id]
          )
          tokens.map { |t| serialize_token(t) }.to_json
        else
          status_code! 422
          "sorry"
        end
      end

      def destroy
        if (session = context.request.session) &&
           (user = session.user) &&
           (token_id = @context.params.url["token_id"])
          token = AuthToken.first(
            "WHERE user_id = ? AND id = ?",
            [user.id, token_id]
          )
          if token
            token.destroy
            serialize_token(token).to_json
          else
            status_code! 404
            "token not found"
          end
        else
          status_code! 422
          "sorry"
        end
      end

      def create
        token = AuthToken.new
        if (session = context.request.session) &&
           (user = session.user) &&
           (token.user_id = user.id.not_nil!.to_i64) &&
           token.save
          serialize_token(token).to_json
        else
          status_code! 422
          {
            errors: "token generation error",
          }.to_json
        end
      end

      private def serialize_token(token : AuthToken)
        {
          id:         token.id,
          token:      token.token,
          expired_at: token.expired_at,
        }
      end

      private def profile_json(user : User)
        puts "~~~ #{user.inspect}"
        {
          id:           user.id,
          name:         user.name,
          email:        user.email,
          log_requests: user.log_requests,
          created_at:   user.created_at,
          tokens:       user.auth_tokens.to_s,
        }.to_json
      end
    end
  end
end
