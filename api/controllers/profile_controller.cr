require "./api_controller"
require "../forms/profile_form"

module Api
  class ProfileController < ApiController
    def show
      if (session = context.request.session) &&
         (user = session.user)
        UserSerializer.new(user).to_json
      else
        fail!
      end
    end

    def update
      form = Api::ProfileForm.from_any(context)
      if form && form.valid? &&
         (session = context.request.session) &&
         (user = form.user)
        form.save!
        UserSerializer.new(user).to_json
      else
        form_error! form
      end
    end
  end
end
