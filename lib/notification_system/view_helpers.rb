module NotificationSystem
  module ViewHelpers
    def notification_settings_form_for(*form_params)
      render 'notification_system/notification_settings_form_for', :form_params => form_params
    end
  end  
end