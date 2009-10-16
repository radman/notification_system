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
    it "deliver should send an email via mailer_class.deliver_[template_name](notification)" do
      Notification.mailer = :user_mailer
      notification = NewCoachingSessionNotification.create! :recipient => User.create!, :date => Time.now
      UserMailer.should_receive(:deliver_new_coaching_session_notification).with(notification)
      notification.deliver
    end
    
    it "deliver should set the sent_at field to the current time" do
      notification = NewCoachingSessionNotification.create! :recipient => User.create!, :date => Time.now
      notification.deliver
      notification.sent_at.should == Time.now
    end
  end

  describe "delivering pending notifications" do
    before(:each) do
      @radu = User.create! :notification_types => [:new_coaching_session_notification, :upcoming_coaching_session_notification]
      
      @pending_wanted = []
      
      3.times do 
        RandomNotification.create! :recipient => @radu, :date => Time.now - 2.days
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
    
  end

  describe "event association" do
    it "should allow associating any type of events" do
      RandomNotification.create! :recipient => User.create!, :date => Time.now, :event => RandomEvent.create!
      RandomNotification.last.event.should be_instance_of(RandomEvent)
    end
  end
end
