class NotificationGenerator < Rails::Generator::NamedBase
  def manifest
    record do |r|
      r.directory 'app/models/notifications'
      r.template 'notification_subclass.rb.erb', "app/models/notifications/#{singular_name}_notification.rb"
    end
  end
end