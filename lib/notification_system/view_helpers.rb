module NotificationSystem
  module ViewHelpers
    def notification_settings_form_for(record_or_name_or_array, *args)
      render 'notification_system/notification_settings_form_for', :record_or_name_or_array => record_or_name_or_array, :args => args
    end
  end  
end