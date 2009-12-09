require File.dirname(__FILE__) + '/../spec_helper'



describe "Notification System" do
  
  # Test Recurrent Notification Scheduling
  #
  # NotificationTypeSubscription.create_scheduled_notifications is called at regular intervals
  #
  # Let x be this scheduling interval
  
  class CoolScheduler
    def initialize(proc)
      @proc = proc
    end

    def run
      @proc.call
    end

    def run_in(interval)
      CoolScheduler.advance_time_by interval
      run
    end
    
    def self.advance_time_by(interval)
      current_time = Time.now
      Time.stubs(:now).returns(current_time + interval)
    end    
  end
  
  describe "normal behaviour" do
    before(:all) do
      @scheduler = CoolScheduler.new(lambda { NotificationTypeSubscription.create_scheduled_notifications })
      freeze_time
    end
    
    it "notification every minute; scheduler runs every minute" do
      recurrence = Recurrence.make :interval => 1.minute, :starts_at => Time.now
      advance_time_by 1.second  # approx. time it takes to create above record
      NotificationTypeSubscription.make :recurrence => recurrence
      advance_time_by 1.second  # approx. time it takes to create above record
      
      # scheduler: iteration 1 
      @scheduler.run_in 3.seconds # first iteration is at unspecified time
      Notification.all.should have(1).record

      # scheduler: iteration 2
      @scheduler.run_in 1.minute
      Notification.all.should have(2).records
      
      # scheduler: iterations 3 - 12
      10.times { @scheduler.run_in 1.minute }      
      Notification.all.should have(12).records
    end

    it "notification every two minutes; scheduler runs every minute" do
      recurrence = Recurrence.make :interval => 2.minutes, :starts_at => Time.now
      advance_time_by 1.second  # approx. time it takes to create above record
      NotificationTypeSubscription.make :recurrence => recurrence
      advance_time_by 1.second  # approx. time it takes to create above record
    
      # scheduler: iteration 1 
      @scheduler.run_in 3.seconds # first iteration is at unspecified time
      Notification.all.should have(1).record

      # scheduler: iteration 2
      @scheduler.run_in 1.minute
      Notification.all.should have(1).records
    
      # scheduler: iterations 3 - 12
      10.times { @scheduler.run_in 1.minute }      
      Notification.all.should have(6).records    
    end

    it "notification every minute; scheduler starts 10 minutes late (after notification is created), runs every minute" do
      recurrence = Recurrence.make :interval => 1.minute, :starts_at => Time.now
      advance_time_by 1.second  # approx. time it takes to create above record
      NotificationTypeSubscription.make :recurrence => recurrence
      advance_time_by 1.second  # approx. time it takes to create above record
      
      # scheduler: iteration 1
      @scheduler.run_in 3.seconds + 10.minutes # first iteration is 10 minutes late
      Notification.all.should have(11).records

      # scheduler: iteration 2
      @scheduler.run_in 1.minute
      Notification.all.should have(12).records
      
      # scheduler: iterations 3 - 12
      10.times { @scheduler.run_in 1.minute }
      Notification.all.should have(22).records
    end

    it "notification every minute; scheduler is down for 1 hour, and otherwise runs every minute" do
      recurrence = Recurrence.make :interval => 1.minute, :starts_at => Time.now
      advance_time_by 1.second  # approx. time it takes to create above record
      NotificationTypeSubscription.make :recurrence => recurrence
      advance_time_by 1.second  # approx. time it takes to create above record
      
      # scheduler: iteration 1
      @scheduler.run_in 3.seconds # first iteration is at unspecified time
      Notification.all.should have(1).records

      # scheduler: iterations 2-11
      10.times { @scheduler.run_in 1.minute }
      Notification.all.should have(11).records
      
      @scheduler.run_in 1.hour # scheduler down for 1 hour
      Notification.all.should have(71).records
    end

    # recurrence changes
    it "notification every minute, then every two minutes, then back to every minute; scheduler runs every minute" do
      recurrence = Recurrence.make :interval => 1.minute, :starts_at => Time.now
      advance_time_by 1.second  # approx. time it takes to create above record
      NotificationTypeSubscription.make :recurrence => recurrence
      advance_time_by 1.second  # approx. time it takes to create above record

      # scheduler: iteration 1
      @scheduler.run_in 3.seconds # first iteration is at unspecified time
      Notification.all.should have(1).records

      # scheduler: iterations 2-11
      10.times { @scheduler.run_in 1.minute }
      Notification.all.should have(11).records

      # change interval to 2 minutes
      recurrence.interval = 2.minutes
      recurrence.save
      
      10.times { @scheduler.run_in 1.minute } # should create 5 records
      Notification.all.should have(16).records
      
      # change interval back to 1 minute
      recurrence.interval = 1.minute
      recurrence.save
      
      10.times { @scheduler.run_in 1.minute } # should create 10 records
      Notification.all.should have(26).records
    end

    # valid; because we may not want to keep all notifications around
    it "notification every minute; scheduler runs every minute; some of the notifications in the middle get deleted" do
      recurrence = Recurrence.make :interval => 1.minute, :starts_at => Time.now
      advance_time_by 1.second  # approx. time it takes to create above record
      NotificationTypeSubscription.make :recurrence => recurrence
      advance_time_by 1.second  # approx. time it takes to create above record
      
      # scheduler: iteration 1
      @scheduler.run_in 3.seconds # first iteration is at unspecified time
      Notification.all.should have(1).records

      # scheduler: iterations 2-11
      10.times { @scheduler.run_in 1.minute }
      Notification.all.should have(11).records

      # delete all 11 notifications
      Notification.delete_all
      
      # scheduler: iterations 12-21
      10.times { @scheduler.run_in 1.minute }
      Notification.all.should have(10).records # should not try to recreate the ones that were deleted
    end
  end
  
  def freeze_time
    current_time = Time.now
    Time.stubs(:now).returns(current_time)
  end
  
  def advance_time_by(interval)
    current_time = Time.now
    Time.stubs(:now).returns(current_time + interval)
  end
  
end