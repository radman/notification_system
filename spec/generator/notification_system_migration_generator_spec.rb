require File.dirname(__FILE__) + '/../spec_helper'

describe "NotificationSystemMigrationGenerator" do
  describe "generating migration" do
    before(:all) do
      Rails::Generator::Scripts::Generate.new.run(["notification_system_migration"], :destination => fake_rails_root)
      @new_files = file_list
      @migration_file = @new_files.select{ |x| x =~ /^#{fake_rails_root}\/db\/migrate\/.*add_notification_system\.rb$/ }.first
    end

    it "should generate a file called db/migrate/*add_notification_system.rb" do
      @migration_file.should_not be_nil
    end
  
    it "should define a AddNotificationSystem class" do
      require @migration_file
      defined?(AddNotificationSystem).should == "constant"
    end
    
    it "the class should inherit from ActiveRecord::Migration" do
      require @migration_file
      AddNotificationSystem.new.should be_kind_of(ActiveRecord::Migration)
    end
  end
end
