module NotificationSystem
  module ViewHelpers
    def notification_settings_form_for(record_or_name_or_array, *args)
      groups = {}
      
      Notification.subscribable_types.each do |subscribable_type|
        groups[subscribable_type.group] ||= []
        groups[subscribable_type.group] << subscribable_type
      end
      
      render 'notification_system/notification_settings_form_for', 
        :record_or_name_or_array => record_or_name_or_array, 
        :args => args,
        :groups => groups
    end
  end  
end