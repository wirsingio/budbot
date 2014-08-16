require 'pry'

module Butbot
  module Dispatcher
    module_function

    COMMANDS = {}

    def dispatch(action)
      COMMANDS.find { |keyword, _| action.include?(keyword) }.last.new
    end

    def register(command)
      COMMANDS[command.keyword] = command
    end
  end
end
