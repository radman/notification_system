require File.dirname(__FILE__) + '/../spec_helper'

describe "UserExtension" do
  
  describe "notification types" do
    it "should be nil on creation" do
      radu = User.new
      radu.notification_types.should be_nil
    end
    
    it "should be invalid if notification_types is not an array and is not nil" do
      radu = User.new :notification_types => "a random string"
      radu.should_not be_valid
    end

    it "should be invalid if notification_types is an array that contains anything other than symbols/strings" do
      radu = User.new :notification_types => ["radu", :coolness, "another string", 1234]
      radu.should_not be_valid    
    end

    it "should be invalid if notification_types is an array of symbols/strings but at least one of the symbols/strings references the Notification class" do
      radu = User.new :notification_types => [:notification, :new_coaching_session_notification]
      radu.should_not be_valid    
    end  

    it "should be invalid if notification_types is an array of symbols/strings but at least one of the symbols/strings references an class that does not inherit from Notification" do
      radu = User.new :notification_types => [:object, :new_coaching_session_notification]
      radu.should_not be_valid    
    end
  
    it "should be valid if notification_types is set to an empty array" do
      radu = User.new :notification_types => []
      radu.should be_valid
    end
    
    it "should ignore empty string arrays" do
      radu = User.create! :notification_types => [:new_coaching_session_notification]
      radu.update_attributes(:notification_types => ['', :new_coaching_session_notification])
      radu.notification_types.should == [:new_coaching_session_notification]
    end

    it "should be valid if notification_types is set to an array of symbols corresponding to subclasses of Notification" do
      radu = User.new :notification_types => [:new_coaching_session_notification, :random_notification, :upcoming_coaching_session_notification]
      radu.should be_valid
    end

    it "should be valid if notification_types is set to an array of strings corresponding to subclasses of Notification" do
      radu = User.new :notification_types => ['new_coaching_session_notification', 'random_notification', 'upcoming_coaching_session_notification']
      radu.should be_valid
    end    

    it "should be valid if notification_types is set to nil" do
      radu = User.create! :notification_types => []
      radu.notification_types = nil
      radu.should be_valid
    end
  end  

  describe "wants_notification?(notification)" do
    before(:each) do
      @radu = User.create!
      @notification = RandomNotification.create! :recipient => @radu, :date => Time.now
    end

    it "should return true if the notification types array references notification.class and the notification has the same recipient" do
      @radu.update_attributes!(:notification_types => [:random_notification, :new_coaching_session_notification])
      @radu.wants_notification?(@notification).should be_true
    end
        
    it "should return false if the notification types array is nil" do
      @radu.update_attributes!(:notification_types => nil)
      @radu.wants_notification?(@notification).should be_false
    end

    it "should return false if the notification types array is empty" do
      @radu.update_attributes!(:notification_types => [])
      @radu.wants_notification?(@notification).should be_false      
    end
    
    it "should return false if the notification types array is not empty and not nil but does not reference notification.class" do
      @radu.update_attributes!(:notification_types => [:new_coaching_session_notification, :upcoming_coaching_session_notification])
      @radu.wants_notification?(@notification).should be_false      
    end
    
    it "should return false if the notification types array is not empty and not nil and references notification.class but the notification has a different recipient" do
      @radu.update_attributes!(:notification_types => [:random_notification, :new_coaching_session_notification])
      @notification.recipient = User.create!
      @notification.save!
      @radu.wants_notification?(@notification).should be_false
    end
  end
  
  describe "subscribed_to_notification_type?(notification_type)" do
    it "should return false if notification types array does not contain symbol corresponding to given string" do
      radu = User.create! :notification_types => [:new_coaching_session_notification]
      radu.is_subscribed_to_notification_type?('blah').should be_false
    end
    it "should return true if notification types array contains symbol corresponding to given string" do
      radu = User.create! :notification_types => [:new_coaching_session_notification]
      radu.is_subscribed_to_notification_type?('new_coaching_session_notification').should be_true
    end    
    it "should return true if notification types array contains string corresponding to given string" do
      radu = User.create! :notification_types => ['new_coaching_session_notification']
      radu.is_subscribed_to_notification_type?('new_coaching_session_notification').should be_true
    end
  end
end 