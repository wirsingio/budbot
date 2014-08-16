require 'spec_helper'

module Budbot::Commands
  describe TimeCommand do
    subject { TimeCommand }
    
    it "tells the current time" do
      Timecop.freeze do
        time = TimeCommand.new('no matter what you pass here').call
        expect(time).to eq Time.now.to_s
      end
    end

    its(:keyword) { is_expected.to be :time }
  end
end
