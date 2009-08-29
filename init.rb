cool_events_path=File.join(RAILS_ROOT,'app','models','cool_events')

$LOAD_PATH << cool_events_path
ActiveSupport::Dependencies.load_paths << cool_events_path

ActiveRecord::Base.observers << :cool_event_observer