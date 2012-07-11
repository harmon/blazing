require 'spec_helper'
require 'blazing/execution_points'

module Blazing

  describe ExecutionPoints do

    describe '.after'
      it 'subscribes the calling recipe to run after the given event' do
        #lambda { ExecutionPoints.after('reset' { }) }.should change(:count).by_one
        #ExecutionPoints.after_reset_queue.should include(block)
      end

    describe '.before'
    describe '.trigger'
  end
end

