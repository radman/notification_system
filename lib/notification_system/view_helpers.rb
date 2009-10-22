module NotificationSystem
  module ViewHelpers
    def notification_settings_form_for(record_or_name_or_array, *args)
      render 'notification_system/notification_settings_form_for', 
        :record_or_name_or_array => record_or_name_or_array, 
        :args => args, 
        :notification_types => Notification.subscribable_types.collect{ |x| x.to_s.underscore }
    end
  end  
end