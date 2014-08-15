require 'json'
require 'uri'
require 'net/http'

require "bundler/setup"
require 'google-search'

DUNNO = "I don't understand..."

helpers do
  def parse_text(text, trigger)
    if text
      text.match(/\A#{trigger}\s*(.*)\z/).captures.first
    end
  end

  def run!(command)
    case command
    when "time"    then Responses.time
    when "bud"     then Responses.bud
    when /weather/ then Responses.weather(command)
    when "cute"    then Responses.cute
    when "bye"     then "See you later"
    else DUNNO
    end
  end
end

post "/run" do
  trigger  = params[:trigger_word]
  text     = params[:text]
  command  = parse_text(text, trigger)
  text     = run!(command)
  JSON.dump(text: text)
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

    def weather(command)
      # only matches cities with one word so far
      city = command.match(/in ([a-zA-Z]+)/).to_a.last || 'Wien'
      in_days = command.match(/in (\d+) days/).to_a.last
      days_in_query = in_days || 7
      url = "http://api.openweathermap.org/data/2.5/forecast/daily?q=#{city}&mode=json&units=metric&cnt=#{days_in_query}"
      STDERR.puts "querying: #{url}"
      data = parse_json_url url
      days = data[:list]
      days = days.slice(in_days.to_i, 1) if in_days
      days
        .map { |day|
          Time.at(day[:dt]).strftime("%a") + ": #{day[:temp][:day]}C"
        }
        .join("\n")
    end

    def cute
      url    = "http://www.reddit.com/r/Aww/hot.json?page=#{1.upto(6).to_a.sample}"
      data   = parse_json_url(url)
      data[:data][:children]
        .map { |image| image[:data][:url] }
        .select { |link| File.extname(link) == ".jpg" }
        .sample
    end

    private

    def parse_json_url url
      body = Net::HTTP.get_response(URI(url)).body
      JSON.parse(body, symbolize_names: true)
    end
  end
end
