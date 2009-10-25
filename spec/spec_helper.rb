# TODOS: 
#   - remove noomii specific tests and tables
#   - see if there's a better way to handle transactions

NOTIFICATION_ROOT = File.expand_path(__FILE__).split('/')[0..-3].join('/')
$: << NOTIFICATION_ROOT

require 'active_record'
require 'rails_generator'
require 'rails_generator/scripts/generate'

Spec::Runner.configure do |config|
  config.before(:suite) do
    setup_database
    setup_generators
    load_plugin_classes
    load_spec_classes
    set_default_time_zone
    stub_current_time
  end

  config.after(:suite) do
    teardown_generators
    teardown_database   
  end

  config.before(:each) do
    reset_tables
  end
  
  def setup_database
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')    
    ActiveRecord::Schema.define(:version => 1) do    
      create_table :users do |t|; end
      create_table :comments do |t|; end

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
    NotificationSystem::Recurrence.delete_all    
    NotificationSystem::NotificationTypeSubscription.delete_all

    Comment.delete_all
    CoachingRelationship.delete_all
    CoachingSession.delete_all
    User.delete_all 
  end

  def setup_generators
    FileUtils.mkdir_p(fake_rails_root) unless File.exists?(fake_rails_root)
    Rails::Generator::Base.sources << Rails::Generator::PathSource.new(:notification_system, File.join(NOTIFICATION_ROOT, "generators"))    
  end
  
  def teardown_generators
    FileUtils.rm_r(fake_rails_root) if File.exists?(fake_rails_root)
  end
  
  def set_default_time_zone
    ActiveRecord::Base.default_timezone = :utc    
  end

  def stub_current_time
    current_time = Time.now
    Time.stub!(:now).and_return(current_time)
  end      
        
  def load_plugin_classes
    require "lib/notification_system"
    require "lib/notification_system/user_extension"
    require "lib/notification_system/notification"  
    require "lib/notification_system/event"
    require "lib/notification_system/view_helpers"    
    include NotificationSystem
  end
  
  def load_spec_classes
    require "spec/spec_classes"
    require "spec/blueprints"
  end
  
  def load_notification_system_migration
    require "generators/notification_system_migration/templates/migration"    
  end
  
  def fake_rails_root
    File.join(File.dirname(__FILE__), 'rails_root')
  end
  
  def file_list
    Dir.glob(File.join(fake_rails_root, '**', '*'))
  end  
end
