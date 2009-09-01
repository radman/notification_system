class EventGenerator < Rails::Generator::NamedBase
  def manifest
    record do |r|
      r.directory 'app/models/events'
      r.template 'event_subclass.rb.erb', "app/models/events/#{singular_name}_event.rb"
      
      r.directory 'app/views/cool_notification_mailer'
      r.template 'mailer_view.erb', "app/views/cool_notification_mailer/#{singular_name}.erb"
    end
  end
end