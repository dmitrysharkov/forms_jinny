module FormsJinny
  module StandardConfig
    module ActiveRecordValidatorsConfig
      def self.configure(jinny)
        jinny.validators_in ActiveRecord::Validations do
          validator :uniqueness,    msg: :taken,    async: :attr
          validator :presence,      msg: :blank
          validator :associated,    msg: :invalid
        end
      end
    end
  end
end