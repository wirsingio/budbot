require 'json'

DUNNO = "I don't understand..."

helpers do
  def parse_for key, str
    str.each_line do |line|
      k, v = line.split("=", 2)
      if k == key
        return v.strip
      end
    end
  end

  def parse_text(text, trigger)
    if text
      command = text.match(/\A#{trigger}\s*(.*)\z/).captures.first
      case command
      when "time?" then Responses.time
      else DUNNO
      end
    end
  end
end

post "/run" do
  body     = request.body.read
  trigger  = params[:trigger_word]     || parse_for("trigger_word", body)
  text     = params[:text]             || parse_for("text", body)
  response = parse_text(text, trigger) || DUNNO
  JSON.dump(text: response)
end

class Responses
  class << self
    def time
      Time.now.to_s
    end
  end
end
