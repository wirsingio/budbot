require_relative '../../../lib/budbot/dispatcher'

describe Butbot::Dispatcher do
  def command_class(class_name, keyword: keyword)
    test_command_class = Class.new do
      define_singleton_method :keyword do
        keyword
      end
    end
    stub_const("TestCommand", test_command_class)
  end

  def random_keyword
    ('a'..'z').to_a.sample(5).join
  end

  it "maps a command string to a command object" do
    some_command_class = command_class("SomeCommand", keyword: random_keyword)
    Butbot::Dispatcher.register(some_command_class)

    keyword = random_keyword
    desired_command_class = command_class("TestCommand", keyword: keyword)

    Butbot::Dispatcher.register(desired_command_class)
    command_object = Butbot::Dispatcher.dispatch("text including the #{keyword} word")
    expect(command_object).to be_a desired_command_class
  end
end
