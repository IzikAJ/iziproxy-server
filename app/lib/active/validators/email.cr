module Active
  module Validators
    module EmailValidator
      EMAIL_REGEX = /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/

      protected def email?(key : String)
        !blank?(key) && self[key] =~ EMAIL_REGEX
      end

      protected def email?(key : Symbol)
        email? key.to_s
      end

      protected def email?(key : String)
        !blank?(key) && self[key] =~ EMAIL_REGEX
      end

      protected def email?(key : Symbol)
        email? key.to_s
      end
    end
  end
end
