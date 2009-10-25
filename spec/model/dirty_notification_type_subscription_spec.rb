require File.dirname(__FILE__) + '/../spec_helper'

describe "NotificationTypeSubscription" do
  it "should be invalid without a subscriber, even if a notification type is specified" do
    s = NotificationTypeSubscription.new :notification_type => 'RandomNotification'
    s.should_not be_valid
  end
  
  it "should be invalid without a notification type, even if a subscriber is specified" do
    s = NotificationTypeSubscription.new :subscriber => User.create!
    s.should_not be_valid
  end
  
  it "should be invalid if notification_type references Notification, even if a subscriber is specified" do
    s = NotificationTypeSubscription.new :notification_type => 'Notification', :subscriber => User.create!
    s.should_not be_valid
  end

  it "should be invalid if notification_type doesn't reference a subclass of notification, even if a subscriber is specified" do
    s = NotificationTypeSubscription.new :notification_type => 'Blah', :subscriber => User.create!
    s.should_not be_valid
  end
  
  it "should be valid if a subscriber and a notification type that's a subclass of Notification are specified" do
    s = NotificationTypeSubscription.new :notification_type => 'RandomNotification', :subscriber => User.create!
    s.should be_valid
  end  
end