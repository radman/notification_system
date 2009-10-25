require File.dirname(__FILE__) + '/../spec_helper'

describe 'UserExtension' do
  before(:each) do
    @radu = User.make
  end
  
  describe 'is_subscribed_to_notification_type?(notification_type) method' do
    it 'should return false if the user is not subscribed to any notifications' do
      @radu.is_subscribed_to_notification_type?('Blah').should be_false
    end
    
    it 'should return false if the user is not subscribed to the notification\'s type' do
      NotificationTypeSubscription.make :subscriber => @radu, :notification_type => 'NewCommentNotification'
      @radu.is_subscribed_to_notification_type?('RandomNotification').should be_false      
    end    

    it 'should return true if the user is subscribed to the notification\'s type' do
      NotificationTypeSubscription.make :subscriber => @radu, :notification_type => 'RandomNotification'
      NotificationTypeSubscription.make :subscriber => @radu, :notification_type => 'NewCommentNotification'
      @radu.is_subscribed_to_notification_type?('RandomNotification').should be_true
    end
  end
    
  describe 'wants_notification?(notification) method' do
    before(:each) do
      @notification = RandomNotification.make :recipient => @radu
    end
    
    it 'should return true if the notification is intended for the user, and the user is subscribed to the notification\'s type' do
      @radu.stubs(:is_subscribed_to_notification_type?).returns(true)
      @radu.wants_notification?(@notification).should be_true
    end

    it 'should return true if the notification\'s type is not subscribable and the notification is intended for the user, even if the user is not subscribed to the notification\'s type' do
      @notification.stubs(:subscribable?).returns(false)
      @radu.stubs(:is_subscribed_to_notification_type?).returns(false)
      @radu.wants_notification?(@notification).should be_false
    end

    it 'should return false if the notification\'s type is subscribable and the user is not subscribed to the notification\'s type, even if the notification is intended for the user' do
      @notification.stubs(:subscribable?).returns(true)
      @radu.stubs(:is_subscribed_to_notification_type?).returns(false)
      @radu.wants_notification?(@notification).should be_false
    end
    
    it 'should return false if the notification is intended for another user, even if the user is subscribed to the notification\'s type' do
      @radu.stubs(:is_subscribed_to_notification_type?).returns(true)
      @notification.update_attributes(:recipient => User.make)
      @radu.wants_notification?(@notification).should be_false
    end
  end
end 