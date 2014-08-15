require 'json'
require 'uri'
require 'net/http'

require "bundler/setup"
require 'google-search'

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
      when "time"    then Responses.time
      when "bud"     then Responses.bud
      when "weather" then Responses.weather
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

    def bud
      res = Google::Search::Image.new(query: "Bud", image_size: :large, file_type: :jpg)
      images = res.all
      images.sample.uri if images.any?
    end

    def weather
      url = "http://api.openweathermap.org/data/2.5/forecast/daily?q=Wien,at&mode=json&units=metric&cnt=7"
      body = Net::HTTP.get_response(URI(url)).body
      days = JSON.parse(body, symbolize_names: true)[:list]
      days.map { |day|
        Time.at(day[:dt]).strftime("%a") + ": #{day[:temp][:day]}C"
      }
      .join("\n")
    end
  end
end
