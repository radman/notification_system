require File.dirname(__FILE__) + '/../spec_helper'

describe 'Notification' do
  before (:all) do
    NotificationMailer = stub_everything('notification mailer') unless defined?(NotificationMailer)
    UserMailer = stub_everything('user mailer') unless defined?(UserMailer)
  end
  
  before(:each) do
    Notification.mailer = nil    
  end

  it 'should be invalid without a recipient' do
    notification = RandomNotification.make_unsaved :recipient => nil
    notification.save
    notification.errors.on(:recipient).should include('can\'t be blank')
  end
  
  it 'should be invalid without a date' do
    notification = RandomNotification.make_unsaved :date => nil
    notification.save
    notification.errors.on(:date).should include('can\'t be blank')
  end
  
  it 'should be valid with a recipient and a date' do
    notification = RandomNotification.make_unsaved :recipient => User.make, :date => Time.now
    notification.save
    notification.should be_valid
  end
    
  it 'should not be considered pending if the current time is before its date' do
    notification = RandomNotification.make :date => Time.now + 2.days
    Notification.pending.should be_empty
  end
    
  it 'should be considered pending if the current time is equal to its date' do
    notification = RandomNotification.make :date => Time.now
    Notification.pending.should have(1).record
  end
  
  it 'should be considered pending if the current time is after its date' do
    notification = RandomNotification.make :date => Time.now - 2.days
    Notification.pending.should have(1).record
  end

  it 'should be considered sent if it\'s sent_at attribute is not nil' do
    10.times do
      n = RandomNotification.make
      n.update_attribute(:sent_at, Time.now)
    end
    
    2.times { RandomNotification.make }
    
    RandomNotification.sent.should have(10).records
  end
  
  it 'should be considered subscribable if it has a title' do      
    NotificationWithTitle.should be_subscribable      
  end
  
  it 'should not be considered subscribable if it does not have a title' do
    EmptyNotification.should_not be_subscribable
  end

  it 'should have the NotificationMailer as the default mailer' do
    Notification.mailer.should == :notification_mailer
  end
  
  it 'should be possible to change the default mailer' do
    Notification.mailer = :user_mailer
    Notification.mailer.should == :user_mailer
  end

  it 'should allow associating any type of events' do
    RandomNotification.make :event => RandomEvent.make
    RandomNotification.last.event.should be_instance_of(RandomEvent)
  end
    
  describe 'once sent' do
    it 'should not be pending, even if the current time is equal to its date' do
      notification = RandomNotification.make :date => Time.now
      notification.deliver
      Notification.pending.should have(0).records
    end

    it 'should not be pending, even if the current time is after its date' do
      notification = RandomNotification.make :date => Time.now - 2.days
      notification.deliver
      Notification.pending.should have(0).records      
    end
  end  

  describe 'when delivered' do
    before(:each) do
      Notification.mailer = :user_mailer
      @radu = User.make
      @notification = RandomNotification.make :recipient => @radu
    end
    
    describe 'and recipient wants it' do
      before(:each) do
        User.any_instance.stubs(:wants_notification?).returns(true)
      end

      it 'should send an email via mailer_class.deliver_[template_name](notification)' do
        UserMailer.expects(:deliver_random_notification).with(@notification)
        @notification.deliver
      end
    
      it 'should set the sent_at field to the current time' do
        @notification.deliver
        @notification.sent_at.to_i.should == Time.now.to_i
      end
    end
    
    describe 'and recipient does not want it' do
      before(:each) do
        User.any_instance.stubs(:wants_notification?).returns(false)
      end      
          
      it 'should not send an email' do
        UserMailer.expects(:deliver_random_notification).never
        @notification.deliver
      end
      
      it 'should destroy the notification' do         
        UserMailer.expects(:deliver_random_notification).never
        @notification.deliver
        Notification.find_by_id(@notification.id).should be_nil
      end
    end
  end

  describe 'deliver_pending class method' do
    before(:each) do
      @pending_notifications = []
      10.times { @pending_notifications << RandomNotification.make }
      Notification.stubs(:pending).returns(@pending_notifications)
    end

    it 'should invoke deliver on each pending notification' do
      @pending_notifications.each { |x| x.expects(:deliver).once }
      Notification.deliver_pending
    end

  end
     
  describe 'title class method' do
    it 'should return nil if no title defined' do
      EmptyNotification.title.should be_nil
    end
    
    it 'should return the appropriate title if title defined' do
      NotificationWithTitle.title.should == 'notification with title'
    end
  end
  
  describe 'group class method' do
    it 'should return nil if no group defined' do
      EmptyNotification.group.should be_nil
    end
    
    it 'should return the appropriate group if group defined' do
      NotificationWithGroup.group.should == 'notification with group'
    end
  end  

  describe '"every" class method' do
    it 'when not called, recurrent? should return false' do
      EmptyNotification.should_not be_recurrent
    end 
    
    it 'when called, recurrent? should return true' do
      DailyNotification.should be_recurrent
    end

    it 'when not called, interval should return nil' do
      EmptyNotification.interval.should be_nil
    end
        
    it 'when called with a one day interval, interval should return 1.day (in seconds)' do
      DailyNotification.interval.should == 1.day
    end
    
    it 'when called without an :at option should raise an argument error' do
      lambda {
        DailyNotification.every(1.day)
      }.should raise_error(ArgumentError, 'No time specified in :at attribute')
    end
    
    it 'when called with an :at option set to "6:00am", time should return "6:00am"' do
      DailyNotification.time.should == '6:00am'
    end
  end  

  describe 'created_after named scope' do
    it 'should return all notifications created after a given date' do
      10.times { |i| n = RandomNotification.make; n.update_attribute(:created_at, Time.now + i.days) }
      RandomNotification.created_after(Time.now + 5.days).count.should == 4
    end
  end

  describe 'types class method' do
    it 'should return all subclasses of Notification' do
      Notification.types.collect { |x| x.to_s }.sort.should == %w( 
          EmptyNotification
          DailyNotification
          NotificationWithGroup
          NotificationWithTitle
          NewCommentNotification
          RandomNotification 
      ).sort      
    end
  end
  
  describe 'subscribable_types class method' do
    it 'should return all subscribable subclasses of Notification' do
      Notification.subscribable_types.collect { |x| x.to_s }.sort.should == %w( 
        NotificationWithTitle
        NewCommentNotification
        RandomNotification
      ).sort
    end    
  end
end
