require File.dirname(__FILE__) + '/../spec_helper'

describe 'NotificationTypeSubscription' do
  it 'should be invalid without a subscriber' do
    s = NotificationTypeSubscription.make_unsaved :subscriber => nil
    s.save
    s.errors.on(:subscriber).should include('can\'t be blank')
  end
  
  it 'should be invalid without a notification type' do
    s = NotificationTypeSubscription.make_unsaved :notification_type => nil
    s.save
    s.errors.on(:notification_type).should include('can\'t be blank')
  end
  
  it 'should be invalid if notification_type references Notification' do
    s = NotificationTypeSubscription.make_unsaved :notification_type => 'Notification'
    s.save
    s.errors.on(:notification_type).should include('must reference a subclass of Notification')
  end
  
  it 'should be invalid if notification_type doesn\'t reference a subclass of notification' do
    s = NotificationTypeSubscription.make_unsaved :notification_type => 'Blah'
    s.save
    s.errors.on(:notification_type).should include('must reference a subclass of Notification')
  end
  
  it 'should be valid if a subscriber and a notification type that\'s a subclass of Notification are specified' do
    s = NotificationTypeSubscription.make_unsaved :notification_type => 'RandomNotification', :subscriber => User.make
    s.save
    s.should be_valid
  end  
end