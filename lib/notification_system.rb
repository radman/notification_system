require 'action_view'
require 'action_controller'

$: << File.expand_path(__FILE__).split('/')[0..-3].join('/') # append plugin root to load path

module NotificationSystem
  autoload :Event,                          'lib/notification_system/event'
  autoload :Notification,                   'lib/notification_system/notification'
  autoload :NotificationTypeSubscription,   'lib/notification_system/notification_type_subscription'
  autoload :Recurrence,                     'lib/notification_system/recurrence'
  autoload :UserExtension,                  'lib/notification_system/user_extension'
  autoload :ViewHelpers,                    'lib/notification_system/view_helpers'
    
  class << self
    def log(msg)
      puts "\x1B[41mNotification System: #{msg}\x1B[0m"
    end

    # TODO: this needs to be made more customizable
    def report_exception(exception)
      HoptoadNotifier.notify(exception) if defined?(HoptoadNotifier)
    end    

    def enable_view_helpers
      return if ActionView::Base.instance_methods.include? 'notification_settings_form_for'
      ActionView::Base.class_eval { include NotificationSystem::ViewHelpers }
    end
    
    def enable_views
      ActionController::Base.view_paths.unshift(File.expand_path(__FILE__).split('/')[0..-3].join('/') + '/lib/app/views')
    end
  end
end

NotificationSystem.enable_view_helpers
NotificationSystem.enable_views
