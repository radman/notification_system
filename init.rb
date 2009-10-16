events_path=File.join(RAILS_ROOT,'app','models','events')
events_path=File.join(RAILS_ROOT,'app','models','notifications')

$LOAD_PATH << events_path
ActiveSupport::Dependencies.load_paths << events_path