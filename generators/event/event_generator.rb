class EventGenerator < Rails::Generator::NamedBase
  def manifest
    record do |r|
      r.directory 'app/models/events'
      r.template 'event_subclass.rb.erb', "app/models/events/#{singular_name}_event.rb"
    end
  end
end