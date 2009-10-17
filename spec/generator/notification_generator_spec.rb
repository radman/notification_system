require File.dirname(__FILE__) + '/../spec_helper'

describe "NotificationGenerator" do
  describe "generating new_comment" do
    before(:all) do
      Rails::Generator::Scripts::Generate.new.run(["notification", "new_comment"], :destination => fake_rails_root)
      @new_files = file_list
    end

    it "should generate a file called app/models/notifications/new_comment_notification.rb when generating new_comment" do
      @new_files.should include(File.join(fake_rails_root, 'app', 'models', 'notifications', 'new_comment_notification.rb'))
    end
  
    it "should define a NewCommentNotification class" do
      require File.join(fake_rails_root, 'app', 'models', 'notifications', 'new_comment_notification.rb')
      defined?(NewCommentNotification).should == "constant"
    end

    it "the class should inherit from Notification" do
      require File.join(fake_rails_root, 'app', 'models', 'notifications', 'new_comment_notification.rb')
      NewCommentNotification.new.should be_kind_of(Notification)
    end
  end
end
