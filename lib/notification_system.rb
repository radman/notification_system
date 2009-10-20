require 'action_view'

$: << File.expand_path(__FILE__).split('/')[0..-3].join('/') # append plugin root to load path

module NotificationSystem
  autoload :Event, 'lib/notification_system/event'
  autoload :Notification, 'lib/notification_system/notification'
  autoload :UserExtension, 'lib/notification_system/user_extension'
  autoload :ViewHelpers, 'lib/notification_system/view_helpers'
  
  class << self
    def enable_view_helpers
      return if ActionView::Base.instance_methods.include? 'notification_settings_form_for'     
      ActionView::Base.class_eval { include NotificationSystem::ViewHelpers }
    end
  end
end


NotificationSystem.enable_view_helpers