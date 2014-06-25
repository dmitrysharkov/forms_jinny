module FormsJinny
  module StandardConfig
    module ActiveModelValidatorsConfig
      def self.configure(jinny)
        jinny.validators_in ActiveModel::Validations do
          validator :confirmation
          validator :acceptance,    msg: :accepted
          validator :presence,      msg: :blank
          validator :absence,       msg: :present
          validator :length,        msg: [
                                            { too_short:  [:within, :in, :minimum] },
                                            { too_long:   [:within, :in, :maximum] },
                                            { is:         :wrong_length }
                                          ]
          validator :format,        msg: :invalid
          validator :inclusion
          validator :exclusion
          validator :numericality,  msg: [
                                            :not_a_number,
                                            :greater_than,
                                            :greater_than_or_equal_to,
                                            :equal_to,
                                            :less_than,
                                            :less_than_or_equal_to,
                                            :only_integer,
                                            :odd,
                                            :even
                                          ]
        end
      end


    end
  end
end