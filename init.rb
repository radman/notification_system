events_path=File.join(RAILS_ROOT,'app','models','events')

$LOAD_PATH << events_path
ActiveSupport::Dependencies.load_paths << events_path

ActiveRecord::Base.observers << :notification_observer
ActiveRecord::Base.observers << :cool_event_observer