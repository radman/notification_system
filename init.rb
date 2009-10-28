events_path=File.join(RAILS_ROOT,'app','models','events')
notifications_path=File.join(RAILS_ROOT,'app','models','notifications')

$: << events_path
$: << notifications_path

ActiveSupport::Dependencies.load_paths << events_path
ActiveSupport::Dependencies.load_paths << notifications_path

ActiveSupport::Dependencies.load_once_paths << events_path
ActiveSupport::Dependencies.load_once_paths << notifications_path

# Load notifications and events into memory
Dir[File.join(events_path, '*')].each { |event_file| require event_file }
Dir[File.join(notifications_path, '*')].each { |notification_file| require notification_file }