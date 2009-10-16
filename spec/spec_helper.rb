# TODOS: 
#   - remove noomii specific tests and tables
#   - see if there's a better way to handle transactions

$: << File.expand_path(__FILE__).split('/')[0..-3].join('/') # root of the plugin

require 'active_record'

Spec::Runner.configure do |config|
  config.before(:suite) do
    setup_database
    load_plugin_classes
    load_spec_classes
    stub_current_time
  end

  config.after(:suite) do
    teardown_database   
  end

  config.before(:each) do
    NotificationMailer = mock("notification mailer", :null_object => true) unless defined?(NotificationMailer)
    reset_tables
  end
  
  def setup_database
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')    
    ActiveRecord::Schema.define(:version => 1) do    
      create_table :users do |t|; end

      create_table :coaching_relationships do |t|
        t.integer :coach_id, :coachee_id
      end      
      
      create_table :coaching_sessions do |t|
        t.integer :coaching_relationship_id
        t.datetime :date
      end      

      load_notification_system_migration && AddNotificationSystem.up
    end
  end

  def teardown_database
    ActiveRecord::Base.connection.tables.each do |table|
      ActiveRecord::Base.connection.drop_table(table)
    end
    ActiveRecord::Base.clear_active_connections!     
  end  

  def reset_tables
    NotificationSystem::Event.delete_all
    NotificationSystem::Notification.delete_all

    CoachingRelationship.delete_all
    CoachingSession.delete_all
    User.delete_all 
  end

  def stub_current_time
    current_time = Time.now
    Time.stub!(:now).and_return(current_time)
  end      
        
  def load_plugin_classes
    require "lib/user_extension"
    require "lib/notification"  
    require "lib/event"
    include NotificationSystem    
  end
  
  def load_spec_classes
    require "spec/spec_classes"
  end
  
  def load_notification_system_migration
    require "generators/notification_system_migration/templates/migration"    
  end
  
end


