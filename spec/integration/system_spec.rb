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
      
  end
  
  
end