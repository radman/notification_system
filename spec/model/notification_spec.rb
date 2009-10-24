require File.dirname(__FILE__) + '/../spec_helper'

describe "Notification" do
  before (:all) do
    NotificationMailer = mock("notification mailer", :null_object => true) unless defined?(NotificationMailer)
    UserMailer = mock("user mailer", :null_object => true) unless defined?(UserMailer)
  end

  it "should be invalid without a recipient even if a date is specified" do
    notification = Notification.new :date => Time.now
    notification.should_not be_valid
  end
  
  it "should be invalid without a date even if a recipient is specified" do
    notification = Notification.new :recipient => User.create!
    notification.should_not be_valid
  end
  
  it "should be valid with a recipient and a date" do
    notification = Notification.new :recipient => User.create!, :date => Time.now
    notification.should be_valid
  end
    
  describe "pending" do
    # a notification is pending if current_time >= notification.date
    # notification.date : when the notification is scheduled to be sent

    it "should not be pending if the current time is before its start_date" do
      notification = RandomNotification.create! :date => Time.now + 2.days, :recipient => User.create!
      Notification.pending.should be_empty
    end
      
    it "should not be pending if it has already been sent, even if the current time is equal to the start date" do
      notification = RandomNotification.create! :date => Time.now, :recipient => User.create!
      notification.deliver
      Notification.pending.should have(0).records
    end
    
    it "should not be pending if it has already been sent, even if the current time is after the start date" do
      notification = RandomNotification.create! :date => Time.now - 2.days, :recipient => User.create!
      notification.deliver
      Notification.pending.should have(0).records      
    end

    it "should be pending if the current time is equal to its start_date" do
      notification = RandomNotification.create! :date => Time.now, :recipient => User.create!
      Notification.pending.should have(1).record
    end
    
    it "should be pending if the current time is after its start_date" do
      notification = RandomNotification.create! :date => Time.now - 2.days, :recipient => User.create!
      Notification.pending.should have(1).record
    end
  end

  describe "delivering" do
    describe "mailer" do
      before(:each) do
        Notification.mailer = nil
      end

      it "should be :notification_mailer by default" do
        Notification.mailer.should == :notification_mailer
      end
      
      it "should be changeable" do
        Notification.mailer = :user_mailer
        Notification.mailer.should == :user_mailer
      end
      
      it "mailer_class method should match the mailer" do
        Notification.mailer = :user_mailer
        Notification.mailer_class.should == UserMailer
      end
    end
    
    # TODO: notification.deliver should send an email via NotificationMailer.deliver_notification_template_name(self)
    it "deliver should send an email via mailer_class.deliver_[template_name](notification) if subscribed" do
      Notification.mailer = :user_mailer
      notification = NewCoachingSessionNotification.create! :recipient => User.create!(:notification_types => [:new_coaching_session_notification]), :date => Time.now
      UserMailer.should_receive(:deliver_new_coaching_session_notification).with(notification)
      notification.deliver
    end

    it "deliver should set the sent_at field to the current time if subscribed" do
      notification = NewCoachingSessionNotification.create! :recipient => User.create!(:notification_types => [:new_coaching_session_notification]), :date => Time.now
      notification.deliver
      notification.sent_at.should == Time.now
    end
    
    it "deliver should not send the notification if recipient not subscribed" do
      Notification.mailer = :user_mailer
      notification = NewCoachingSessionNotification.create! :recipient => User.create!, :date => Time.now
      UserMailer.should_not_receive(:deliver_new_coaching_session_notification).with(notification)
      notification.deliver
    end
    
    it "deliver should not destroy notification if recipient not subscribed" do
      Notification.mailer = :user_mailer
      notification = NewCoachingSessionNotification.create! :recipient => User.create!, :date => Time.now
      UserMailer.should_not_receive(:deliver_new_coaching_session_notification).with(notification)
      notification.deliver
      Notification.find_by_id(notification.id).should be_nil
    end    
    
  end

  # this tests too much; we should just test that it calls deliver for each pending notification
  describe "delivering pending notifications" do
    before(:each) do
      @radu = User.create! :notification_types => [:new_coaching_session_notification, :upcoming_coaching_session_notification]
      
      @pending_wanted = []
      @pending_unwanted = []

      3.times do 
        @pending_unwanted << RandomNotification.create!(:recipient => @radu, :date => Time.now - 2.days)
        @pending_wanted << NewCoachingSessionNotification.create!(:recipient => @radu, :date => Time.now - 30.seconds)
      end
      
      2.times do
        RandomNotification.create! :recipient => @radu, :date => Time.now + 2.days
      end
    end
    
    it "Notification.deliver_pending should invoke deliver on each pending notification that the user wants to receive" do
      Notification.deliver_pending
      sent_notifications = Notification.all.select { |x| !x.sent_at.nil? }
      
      sent_notifications.collect(&:id).sort.should == @pending_wanted.collect(&:id).sort
    end
    
    it "deliver pending should result in zero remaining pending notifications" do
      Notification.deliver_pending
      Notification.pending.should have(0).records
    end
    
  end

  describe "event association" do
    it "should allow associating any type of events" do
      RandomNotification.create! :recipient => User.create!, :date => Time.now, :event => RandomEvent.create!
      RandomNotification.last.event.should be_instance_of(RandomEvent)
    end
  end

  describe "syntax sugar" do
    describe "title set via class method" do
      before(:all) do
        class CoolNotification < NotificationSystem::Notification
          title 'coolest notification ever'
        end
      end

      it "should return the same title when accessed" do
        CoolNotification.title.should == 'coolest notification ever'
      end
    end
  end

  describe "recurrent? instance method" do
    it "should return true if it has a recurrence" do
      recurrence = Recurrence.create! :interval => 1
      notification = RandomNotification.create! :recipient => User.create!, :date => Time.now, :recurrence => recurrence
      notification.should be_recurrent
    end
    
    it "should return false if it does not have a recurrence" do
      notification = RandomNotification.create! :recipient => User.create!, :date => Time.now
      notification.should_not be_recurrent
    end
  end
  
  describe "recurrent notifications" do    
    describe "when delivered" do
      before(:each) do
        @user = User.create!
        @event = RandomEvent.create!
        @recurrence = Recurrence.create! :interval => 10.days
        @notification = RandomNotification.create! :date => Time.now, :recurrence => @recurrence, :recipient => @user, :event => @event
      end
      
      describe "and its recurrence does not have a recurrence_end_date" do
        it "should create another notification with same type, recipient, event, interval, and with date increased by the interval" do
          @notification.recurrence.update_attributes(:end_date => nil)
          @notification.deliver
          RandomNotification.exists?(:date => Time.now + @recurrence.interval, :recipient_id => @user.id, :event_id => @event.id, :recurrence_id => @recurrence.id).should be_true
        end
      end
      
      describe "and its recurrence has an end date" do
        it "should not create another notification if date+end_date > recurrence_end_date" do
          @notification.recurrence.update_attributes(:end_date => Time.now + @recurrence.interval - 1)
          @notification.deliver
          RandomNotification.exists?(:date => Time.now + @recurrence.interval, :recipient_id => @user.id, :event_id => @event.id, :recurrence_id => @recurrence.id).should be_false
        end  
          
        it "should create another notification with same type, recipient, event, interval, and with date increased by the interval, if date+end_date < recurrence_end_date" do
          @notification.recurrence.update_attributes(:end_date => Time.now + @recurrence.interval + 1)
          @notification.deliver
          RandomNotification.exists?(:date => Time.now + @recurrence.interval, :recipient_id => @user.id, :event_id => @event.id, :recurrence_id => @recurrence.id).should be_true
        end

        it "should create another notification with same type, recipient, event, interval, and with date increased by the interval, if date+end_date = recurrence_end_date" do
          @notification.recurrence.update_attributes(:end_date => Time.now + @recurrence.interval)
          @notification.deliver
          RandomNotification.exists?(:date => Time.now + @recurrence.interval, :recipient_id => @user.id, :event_id => @event.id, :recurrence_id => @recurrence.id).should be_true
        end     
      end
    end
  end

  describe "sent" do
    it "should be considered sent if it's sent_at attribute is not nil" do
      10.times do
        n = RandomNotification.create! :recipient => User.create!(:notification_types => [:random_notification]), :date => Time.now
        n.deliver
      end
      
      2.times { RandomNotification.create! :recipient => User.create!, :date => Time.now }
      
      RandomNotification.sent.should have(10).records
    end
  end
  
  describe "subscribable" do
    before(:all) do
      class SubscribableNotification < NotificationSystem::Notification
        title 'a title'
      end

      class UnsubscribableNotification < NotificationSystem::Notification; end
           
    end
    
    it "should be subscribable if it has a title" do      
      SubscribableNotification.should be_subscribable      
    end
    
    it "should not be subscribable if it does not have a title" do
      UnsubscribableNotification.should_not be_subscribable
    end
    
    it "should always be delivered if not subscribable" do
      unsubscribed_user = User.create!
      subscribed_user = User.create! :notification_types => [:unsubscribable_notification]
      UnsubscribableNotification.create! :recipient => subscribed_user, :date => Time.now
      UnsubscribableNotification.create! :recipient => unsubscribed_user, :date => Time.now
      Notification.deliver_pending
      Notification.sent.should have(2).records
    end
    
    it "should only be delivered if subscribed to, if subscribable" do
      unsubscribed_user = User.create!
      subscribed_user = User.create! :notification_types => [:subscribable_notification]
      SubscribableNotification.create! :recipient => subscribed_user, :date => Time.now
      SubscribableNotification.create! :recipient => unsubscribed_user, :date => Time.now
      Notification.deliver_pending
      Notification.sent.should have(1).record
    end
  end
end
