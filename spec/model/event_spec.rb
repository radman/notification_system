require File.dirname(__FILE__) + '/../spec_helper'

describe "Event" do
  describe "trigger" do
    it "should create an event when" do
      lambda {
        RandomEvent.trigger
      }.should change(RandomEvent, :count).from(0).to(1)
    end
  
    it "should create an event with correct source attribute" do
      source = CoachingRelationship.create!
      RandomEvent.trigger(:stuff => 'ignore me', :source => source, :more_stuff => 'ignore me')
      RandomEvent.first.source.should_not be_nil
      RandomEvent.first.source.id.should == source.id    
    end
  
    describe "extra attributes" do
      it "when not specified, data should be nil" do
        source = CoachingRelationship.create!
        RandomEvent.trigger(:source => source)
        RandomEvent.first.data.should be_nil
      end
      
      it "when specified, should be serialized as a hash called 'data'" do
        source = CoachingRelationship.create!
        RandomEvent.trigger(:source => source, :some_numbers => [2,4,6,8], :a_string => 'radu was here')
        RandomEvent.first.data.should be_kind_of(Hash)
        RandomEvent.first.data[:some_numbers].should == [2,4,6,8]
        RandomEvent.first.data[:a_string].should == 'radu was here'
      end
    end

    describe "validates_source_type class method" do
      before(:all) do
        class ValidatedEvent < NotificationSystem::Event
          validates_source_type :coaching_relationship
        end
      end
      
      it "should be invalid if the source's class doesn't match the specified source_type" do
        e = ValidatedEvent.trigger :source => User.create!
        e.errors.on(:source).should include('must be an instance of CoachingRelationship')
      end
      
      it "should be valid if the source's class matches the specified source_type" do
        e = ValidatedEvent.trigger :source => CoachingRelationship.create!
        e.should be_valid
      end      
    end

  end
end
