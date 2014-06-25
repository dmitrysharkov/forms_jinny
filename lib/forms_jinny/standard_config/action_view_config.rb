module FormsJinny
  module StandardConfig
    module ActionViewConfig
      def self.configure(jinny)
        jinny.patch_view  :text_field, :password_field, :file_field, :text_area,
                          :check_box, :radio_button, :color_field, :search_field,
                          :telephone_field, :date_field, :time_field, :datetime_field,
                          :datetime_local_field, :month_field, :week_field, :url_field,
                          :email_field, :number_field, :range_field

        jinny.patch_view  :select, :time_zone_select,
                          :collection_select, :collection_radio_buttons, :collection_check_boxes,
                          :grouped_collection_select
      end
    end
  end
end