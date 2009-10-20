module NotificationSystem
  module ViewHelpers
    def notification_settings_form_for(user)
      render 'notification_system/notification_settings_form_for', :user => user
    end
  end  
end