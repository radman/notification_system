class CoolEventGenerator < Rails::Generator::NamedBase
  def manifest
    record do |r|
      r.directory 'app/models/cool_events'
      r.template 'cool_event_subclass.rb.erb', "app/models/cool_events/#{singular_name}_cool_event.rb"
      
      r.directory 'app/views/notification_mailer'
      r.template 'mailer_view.erb', "app/views/notification_mailer/#{singular_name}.erb"
    end
  end
end