require 'pry'

module Budbot
  module Dispatcher
    module_function

    COMMANDS = {}
    COMMANDS.default = -> { "I don't understand…" }

    def dispatch(action)
      key = COMMANDS.keys.find { |keyword| action.include?(keyword.to_s) }
      COMMANDS[key]
    end

    def register(command)
      COMMANDS[command.keyword] = command.new
    end
  end
end
