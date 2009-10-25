require File.dirname(__FILE__) + '/../spec_helper'

describe 'Recurrence' do
  it 'should be invalid without an interval' do
    recurrence = Recurrence.make_unsaved
    recurrence.save
    recurrence.errors.on(:interval).should include('can\'t be blank')
  end

  it 'should be invalid with a negative interval' do
    recurrence = Recurrence.make_unsaved :interval => -7
    recurrence.save
    recurrence.errors.on(:interval).should include('must be greater than zero')
  end  
  
  it 'should be valid with a positive non-zero interval' do
    recurrence = Recurrence.make_unsaved :interval => 1
    recurrence.should be_valid
  end  
end
