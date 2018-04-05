require "./api_form"

module Api
  class ProfileForm < ApiForm
    property email : String?
    property name : String?
    property password : String?
    property user : User?

    accesible name, email, password, log_requests

    JSON.mapping({
      email:        String?,
      name:         String?,
      password:     String?,
      log_requests: Bool?,
    })

    def allow_clear?(key : String)
      return true if key == "name"
      false
    end

    def save!
      # TODO
      if _user = user
        {% for key in %w{email name password log_requests} %}
          if allow_clear?({{key}}) || present?({{key}})
            puts "<<< #{{{key}}} #{self.{{key.id}}}"
            _user.{{key.id}} = self.{{key.id}}
          end
        {% end %}
        _user.save
      end
    end

    def self.from_any(context : HTTP::Server::Context) : ProfileForm?
      if (form = self.from_body(context)) &&
         (session = context.request.session) &&
         (user = session.user)
        form.user = user
        return form
      end
    end

    def valid?
      validate email, email
      # validate email, present, email
      # validate password, present

      # add_error(:email, "invalid") if user.nil?
      # add_error(:password, "invalid") unless correct_password?
      errors.empty?
    end
  end
end
