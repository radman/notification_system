class CoolNotificationMailerGenerator < Rails::Generator::Base
  
  def manifest
    record do |r|
      r.template 'mailer.rb.erb', 'app/models/cool_notification_mailer.rb'
    end
  end
  
end