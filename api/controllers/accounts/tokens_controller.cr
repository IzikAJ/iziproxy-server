require "../api_controller"
require "../../forms/profile_form"

module Api
  module Accounts
    class TokensController < ApiController
      def index
        if (session = context.request.session) &&
           (user = session.user)
          profile_json user
        else
          status_code! 422
          "sorry"
        end
      end

      def destroy
        if (session = context.request.session) &&
           (user = session.user)
          profile_json user
        else
          status_code! 422
          "sorry"
        end
      end

      def create
        form = Api::ProfileForm.from_any(context)
        if form && form.valid? &&
           (session = context.request.session) &&
           (user = form.user)
          form.save!
          profile_json user
        else
          status_code! 422
          {
            errors: form.try(&.errors),
          }.to_json
        end
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
