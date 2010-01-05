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

  describe 'notifications association' do
    it 'should return all notifications of type self.notification_type in which self.subscriber is a recipient' do
      radu = User.make
      subscription = NotificationTypeSubscription.make :subscriber => radu, :notification_type => 'RandomNotification'

      10.times { RandomNotification.make :recipient => radu }
      5.times { RandomNotification.make :recipient => User.make }
      5.times { NewCommentNotification.make :recipient => radu }
      
      subscription.notifications.should have(10).records
    end
  end

  describe 'recurrent named scope' do
    it 'should return all subscriptions that are associated to a recurrence' do
      5.times { NotificationTypeSubscription.make :recurrence => Recurrence.make }
      3.times { NotificationTypeSubscription.make }
      
      NotificationTypeSubscription.recurrent.should have(5).records
    end
  end
  
  describe 'create_scheduled_notifications class method' do
    it 'should call create_scheduled_notifications on each recurrent subscription' do
      5.times { NotificationTypeSubscription.make :recurrence => Recurrence.make }
      3.times { NotificationTypeSubscription.make } # note: these are not recurrent
      
      NotificationTypeSubscription.any_instance.expects(:create_scheduled_notifications).times(5)
      
      NotificationTypeSubscription.create_scheduled_notifications
    end
    
    # ERROR HANDLING (TODO: these tests are not finished)
    describe 'when an instance method (also called create_scheduled_notifications) fails' do
      it 'should still try to create the rest' do
        NotificationTypeSubscription.make :recurrence => Recurrence.make
        NotificationTypeSubscription.make :recurrence => Recurrence.make

        NotificationTypeSubscription.any_instance.expects(:create_scheduled_notifications).times(2).raises(Exception).then.returns(true)
        
        NotificationTypeSubscription.create_scheduled_notifications
      end
    end
    
  end
  
end