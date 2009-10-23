module NotificationSystem
  module ViewHelpers
    def notification_settings_for(user)
      groups = {}
      
      Notification.subscribable_types.each do |subscribable_type|
        groups[subscribable_type.group] ||= []
        groups[subscribable_type.group] << subscribable_type
      end
      
      render 'notification_system/notification_settings_for', :user => user, :groups => groups
    end
  end  
end