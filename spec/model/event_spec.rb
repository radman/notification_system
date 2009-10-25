require File.dirname(__FILE__) + '/../spec_helper'

describe 'Event' do
  describe 'when triggered' do
    it 'should create an instance' do
      lambda { RandomEvent.trigger }.should change(RandomEvent, :count).from(0).to(1)
    end
  
    describe 'with a source' do
      it 'should create an instance with the specified source attribute' do
        source = Comment.make
        RandomEvent.trigger :source => source
        RandomEvent.first.source.should == source
      end
    end

    describe 'with extra attributes' do
      it 'should serialize the extra attributes as a hash called "data"' do
        source = Comment.make
        RandomEvent.trigger :source => source, :some_numbers => [2, 4, 6, 8], :a_string => 'radu was here'
        RandomEvent.first.data.should == {
          :some_numbers => [2, 4, 6, 8],
          :a_string => 'radu was here'
        }
      end
    end
      
    describe 'without extra attributes' do
      it 'should create an instance with a nil data attribute' do
        RandomEvent.trigger :source => Comment.make
        RandomEvent.first.data.should be_nil
      end
    end

    describe 'with a source_type defined on the Event' do
      it 'should be invalid if the source\'s class doesn\'t match the specified source_type' do
        e = EventWithCommentSourceType.trigger :source => User.make
        e.errors.on(:source).should include('must be an instance of Comment')
      end
    
      it 'should be valid if the source\'s class matches the specified source_type' do
        e = EventWithCommentSourceType.trigger :source => Comment.make
        e.should be_valid
      end      
    end
  end
end
