require File.dirname(__FILE__) + '/../spec_helper'

describe "EventGenerator" do
  describe "generating new_comment" do
    before(:all) do
      Rails::Generator::Scripts::Generate.new.run(["event", "new_comment"], :destination => fake_rails_root)
      @new_files = file_list
    end

    it "should generate a file called app/models/events/new_comment_event.rb when generating new_comment" do
      @new_files.should include(File.join(fake_rails_root, 'app', 'models', 'events', 'new_comment_event.rb'))
    end
  
    it "should define a NewCommentEvent class" do
      require File.join(fake_rails_root, 'app', 'models', 'events', 'new_comment_event.rb')
      defined?(NewCommentEvent).should == "constant"
    end

    it "the class should inherit from Event" do
      require File.join(fake_rails_root, 'app', 'models', 'events', 'new_comment_event.rb')
      NewCommentEvent.new.should be_kind_of(Event)
    end
  end
end