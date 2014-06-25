module FormsJinny
  module Actionpack
    class AsyncValidationController < ::ApplicationController
      def validate_new_attribute
        entity = model.new(model_params)
        send_attribute_results(entity)
      end

      def validate_attribute
        entity = model.new(model_params)
        send_attribute_results(entity)
      end

      private

      def send_attribute_results(entity)
        entity.valid?
        attribute_messages = entity.errors[attribute]
        if attribute_messages.empty?
          json = { status: :ok }
        else
          json = { status: :failed,  errors: attribute_messages  }
        end
        render json: json
      end

      def model
        params[:model].camelize.constantize
      end

      def id
        params[:id]
      end

      def enitity_name
        params[:model].underscore
      end

      def attribute
        params[:attribute]
      end

      def model_params
        params.require(enitity_name.to_sym).dup.permit!
      end
    end
  end
end