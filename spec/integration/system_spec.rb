require File.dirname(__FILE__) + '/../spec_helper'

# NOTES:
# - certain notifications don't require subscriptions
# - ** this only tests that notifications are created! **
# - ** we also have to test the models and the scheduler **
# - TODO: always create notification; because subscription status may change by the time the notification is scheduled to be sent

describe "Notification System" do
  
  describe "Radu schedules a session with Jerry for 2 days from now" do
    before(:each) do
      @radu = User.create!
      @jerry = User.create!
      @coaching_relationship = CoachingRelationship.create! :coach => @radu, :coachee => @jerry

      @coaching_session_date = Time.now + 10.days

      @coaching_session_creation = lambda {
        CoachingSession.create! :coaching_relationship => @coaching_relationship, :date => @coaching_session_date, :creator => @radu
      }
    end
    
    describe "NewCoachingSessionEvent" do
      it "should be created" do
        @coaching_session_creation.should change(NewCoachingSessionEvent, :count).from(0).to(1)
      end
      
      it "should have the new coaching session as the source" do
        coaching_session = @coaching_session_creation.call
        NewCoachingSessionEvent.first.source.should == coaching_session
      end
    end

    it "should create a new session notification for Jerry to be sent ASAP" do
      @coaching_session_creation.should change {
        NewCoachingSessionNotification.count(:conditions => { :recipient_id => @jerry.id, :date => Time.now })
      }.from(0).to(1)
    end      

    it "should create a upcoming session notification for Radu to be sent a day before the session" do
      @coaching_session_creation.should change {
        UpcomingCoachingSessionNotification.count(:conditions => { :recipient_id => @radu.id, :date => @coaching_session_date - 1.day })
      }.from(0).to(1)
    end
    
    it "should create a upcoming session notification for Jerry to be sent a day before the session" do
      @coaching_session_creation.should change {
        UpcomingCoachingSessionNotification.count(:conditions => { :recipient_id => @jerry.id, :date => @coaching_session_date - 1.day })
      }.from(0).to(1)
    end      

    it "should create a random notification for Radu to be sent a day before the session" do
      @coaching_session_creation.should change {
        RandomNotification.count(:conditions => { :recipient_id => @radu.id, :date => @coaching_session_date - 1.day })
      }.from(0).to(1)
    end

    it "should create a random notification for Jerry to be sent a day before the session" do
      @coaching_session_creation.should change {
        RandomNotification.count(:conditions => { :recipient_id => @jerry.id, :date => @coaching_session_date - 1.day })
      }.from(0).to(1)
    end
    
    describe "and Jerry and Radu have the following set of notification settings" do
      
      # Notification Types
      # - someone has scheduled a coaching session with you (Jerry wants to receive these, Radu doesn't)
      # - you have a session scheduled a day from now (Jerry does not want to receive these, and Radu does)
      # - random notification a day before a session is due (you always receive these)
      
      before(:each) do
        # Method Name
        # - can't call it "notifications" because we're associating to a type of notification
        
        # @radu.notification_types = [:upcoming_coaching_session, :random]
        # @jerry.notification_types = [:new_coaching_session, :random]
      end
      
      # time tests are likely to contain some error
            
    end
    
  end
  
  
end