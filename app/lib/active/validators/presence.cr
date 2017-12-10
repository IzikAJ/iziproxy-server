module Active
  module Validators
    module PresenceValidator
      BLANK_REGEX = /^\s*$/

      protected def blank?(key : String)
        self[key].nil? || self[key] =~ BLANK_REGEX
      end

      protected def blank?(key : Symbol)
        blank? key.to_s
      end

      protected def present?(key : String)
        !blank?(key)
      end

      protected def present?(key : Symbol)
        present? key.to_s
      end
    end
  end
end
