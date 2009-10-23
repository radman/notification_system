module NotificationSystem
  module ViewHelpers
    def notification_settings_for
      groups = {}
      
      Notification.subscribable_types.each do |subscribable_type|
        groups[subscribable_type.group] ||= []
        groups[subscribable_type.group] << subscribable_type
      end
      
      render 'notification_system/notification_settings_for', :groups => groups
    end
  end  
end