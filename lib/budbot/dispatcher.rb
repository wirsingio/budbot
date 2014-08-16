require 'pry'

module Budbot
  module Dispatcher
    module_function

    COMMANDS = {}

    def dispatch(action)
      _, command = COMMANDS.find { |keyword, _| action.include?(keyword.to_s) }
      if command
        command.new
      else
        -> { "I don't understand…" }
      end
    end

    def register(command)
      COMMANDS[command.keyword] = command
    end
  end
end
