require File.dirname(__FILE__) + '/../spec_helper'

describe "Notification System" do
  # TODO: write some integration specs

  before(:each) do
    @radu = User.make
    @notification_type = 'RandomNotification'
  end

  # describe 'daily notification that starts in 1 day and ends in 10 days' do
  #   before(:each) do
  #     @recurrence = Recurrence.make :interval => 1.day, :starts_at => Time.now + 1.day, :ends_at => Time.now + 10.days
  #     @subscription = NotificationTypeSubscription.make :subscriber => @radu, :notification_type => @notification_type, :recurrence => @recurrence    
  #   end
  #   
  #   describe 'when no notifications have been created' do
  #     it 'should not create one if the recurrence has not yet started' do
  #       Time.stubs(:now).returns(@recurrence.starts_at - 30.minutes)
  #       @subscription.create_scheduled_notifications
  #       @subscription.notifications(true).should have(0).records
  #       Notification.pending.should have(0).records
  #     end
  #     
  #     it 'should create one if the recurrence has just started' do
  #       Time.stubs(:now).returns(@recurrence.starts_at)
  #       @subscription.create_scheduled_notifications
  #       @subscription.notifications(true).should have(1).records
  #       Notification.pending.should have(1).records
  #     end
  #     
  #     it 'should create one if the recurrence has passed its first occurrence but not yet reached its second occurrence' do
  #       Time.stubs(:now).returns(@recurrence.starts_at + 30.minutes)
  #       @subscription.create_scheduled_notifications
  #       @subscription.notifications(true).should have(1).records
  #       Notification.pending.should have(1).records
  #     end
  #     
  #     it 'should create two if the recurrence has just reached its second occurrence' do
  #       Time.stubs(:now).returns(@recurrence.starts_at + @recurrence.interval)
  #       @subscription.create_scheduled_notifications
  #       @subscription.notifications(true).should have(2).records
  #       Notification.pending.should have(2).records
  #     end      
  #     
  #     it 'should create two if the recurrence has passed its second occurrence but not yet reached its third occurrence' do
  #       Time.stubs(:now).returns(@recurrence.starts_at + @recurrence.interval + 30.minutes)
  #       @subscription.create_scheduled_notifications
  #       @subscription.notifications(true).should have(2).records
  #       Notification.pending.should have(2).records
  #     end      
  #     
  #     it 'should create seven if the recurrence has just reached passed its 7th occurrence' do
  #       Time.stubs(:now).returns(@recurrence.starts_at + 6 * @recurrence.interval)
  #       @subscription.create_scheduled_notifications
  #       @subscription.notifications(true).should have(7).records
  #       Notification.pending.should have(7).records
  #     end      
  #     
  #     it 'should create seven if the recurrence has passed its 7th occurrence but not yet reached its 8th occurrence' do
  #       Time.stubs(:now).returns(@recurrence.starts_at + 6 * @recurrence.interval + 30.minutes)
  #       @subscription.create_scheduled_notifications
  #       @subscription.notifications(true).should have(7).records
  #       Notification.pending.should have(7).records
  #     end
  #     
  #     it 'should only create 10 even if the recurrence would have passed its 100th occurrence, with an ends_at' do
  #       Time.stubs(:now).returns(@recurrence.starts_at + 99 * @recurrence.interval + 30.minutes)
  #       @subscription.create_scheduled_notifications
  #       @subscription.notifications(true).should have(10).records
  #       Notification.pending.should have(10).records        
  #     end
  #   end
  # 
  #   describe 'when two notifications have been created' do
  #     before(:each) do
  #       Time.stubs(:now).returns(@recurrence.starts_at + @recurrence.interval)
  #       @subscription.create_scheduled_notifications        
  #     end
  #     
  #     it 'should not create one if the recurrence has not yet reached its third occurrence' do
  #       Time.stubs(:now).returns(@recurrence.starts_at + @recurrence.interval + 30.minutes)
  # 
  #       lambda {
  #         @subscription.create_scheduled_notifications 
  #       }.should_not change(Notification.pending, :count)
  #     end
  # 
  #     it 'should create one if the recurrence has reached its third occurrence' do
  #       Time.stubs(:now).returns(@recurrence[2])
  # 
  #       lambda {
  #         @subscription.create_scheduled_notifications 
  #       }.should change(Notification.pending, :count).from(2).to(3)
  #     end
  #     
  #     it 'should create 8 if the recurrence has reached its 10th occurrence' do
  #       Time.stubs(:now).returns(@recurrence[9])
  # 
  #       lambda {
  #         @subscription.create_scheduled_notifications 
  #       }.should change(Notification.pending, :count).from(2).to(10)
  #     end 
  # 
  #     it 'should only create 8 even if the recurrence would have passed its 100th occurrence, with an ends_at' do
  #       Time.stubs(:now).returns(@recurrence.starts_at + 99 * @recurrence.interval + 30.minutes)
  #       lambda {
  #         @subscription.create_scheduled_notifications 
  #       }.should change(Notification.pending, :count).from(2).to(10)       
  #     end      
  #   end
  # 
  #   describe 'when recurrence interval is changed to weekly after two notifications have been sent' 
  # end
  
  describe 'weekly notification that starts now' do
    before(:each) do
      @recurrence = Recurrence.make :interval => 1.week, :starts_at => Time.now
      @subscription = NotificationTypeSubscription.make :subscriber => @radu, :notification_type => @notification_type, :recurrence => @recurrence    
    end
    
    describe 'after 1 week has passed and second notification has been sent, and user changes recurrence to daily' do
      before(:each) do
        Time.stubs(:now).returns(@recurrence.starts_at + 1.week + 30.minutes)
        @subscription.create_scheduled_notifications
        @recurrence.update_attributes(:interval => 1.day)
        @subscription.reload
      end

      it 'should create one notification if recurrence has just reached its 8th day; and it should be scheduled for 8 days after the recurrence started' do
        Time.stubs(:now).returns(@recurrence.starts_at + 8.days)
        
        lambda {
          @subscription.create_scheduled_notifications 
        }.should change(Notification.pending, :count).from(2).to(3)
        
        # test actual date as well
      end
    end
  end

  # it 'should work when recurrence parameters are kept constant' do
  #   # I want to subscribe to daily random notifications (starting tomorrow and lasting 2 days}
  #   @radu = User.make
  #   @notification_type = 'RandomNotification'
  #   @recurrence = Recurrence.make :interval => 1.day, :starts_at => Time.now + 1.day, :ends_at => Time.now + 3.days
  #   @subscription = NotificationTypeSubscription.make :subscriber => @radu, :notification_type => @notification_type, :recurrence => @recurrence
  #   
  #   # @subscription.create_scheduled_notifications
  #   # @subscription.notifications(true).should have(0).records
  #   # Notification.pending.should have(0).records
  #   
  #   # Time.stubs(:now).returns(@subscription.created_at + 1.day)
  #   # @subscription.create_scheduled_notifications
  #   # @subscription.notifications(true).should have(1).record
  #   # Notification.pending.should have(1).record
  # 
  #   Time.stubs(:now).returns(@subscription.created_at + 2.days)
  #   @subscription.create_scheduled_notifications
  #   @subscription.notifications(true).should have(2).records
  #   Notification.pending.should have(2).records
  # 
  #   
  # end

    # it 'full out test' do
    #   @radu = User.make
    #   @recurrence = Recurrence.make :interval => 1.day, :end_date => Time.now + 3.days
    #   @schedule = Schedule.make :date => :recurrence => @recurrence
    #   @subscription = NotificationTypeSubscription.make :subscriber => @radu, :notification_type => 'RandomNotification', :schedule => @schedule
    # 
    #   Notification.pending.should have(0).records
    # 
    #   # need to test 1.day+epsilon and 1.day-epsilon
    #   Time.stubs(:now).returns(@subscription.created_at + 1.days)
    #   @subscription.create_scheduled_notifications
    # 
    #   Notification.pending.should have(1).record
    #   @subscription.notifications(true).should have(1).record
    # 
    #   Time.stubs(:now).returns(@subscription.created_at + 2.days)
    #   @subscription.create_scheduled_notifications
    # 
    #   Notification.pending.should have(2).records
    #   @subscription.notifications(true).should have(2).records
    #   # also need to test that create_scheduled_notifications will create multiple if some have been skipped       
    # end
end