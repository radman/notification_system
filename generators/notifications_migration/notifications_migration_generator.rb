class NotificationsMigrationGenerator < Rails::Generator::Base
  
  def manifest
    record do |r|
      r.migration_template 'migration.rb', 'db/migrate'
    end
  end
  
  def file_name
    'add_notifications'
  end
  
end