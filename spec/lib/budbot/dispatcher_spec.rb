require 'spec_helper'

module Budbot
  describe Dispatcher do
    def command_class(keyword: keyword)
      Class.new do
        define_singleton_method :keyword do
          keyword
        end
      end
    end

    def random_keyword
      ('a'..'z').to_a.sample(5).join.to_sym
    end

    it 'maps a command string to a command object' do
      some_command_class = command_class(keyword: random_keyword)
      Dispatcher.register(some_command_class)

      keyword = random_keyword
      desired_command_class = command_class(keyword: keyword)

      Dispatcher.register(desired_command_class)
      command_object = Dispatcher.dispatch("text including the #{keyword} word")
      expect(command_object).to be_a desired_command_class
    end

    it "returns a nil command if it can't find a command" do
      command_object = Dispatcher.dispatch('text with no keyword')
      expect(command_object).to respond_to :call
    end
  end
end
