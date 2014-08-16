module Budbot::Commands
  class TimeCommand < Struct.new(:command)
    def self.keyword
      :time
    end

    def call
      Time.now.to_s
    end
  end
end
