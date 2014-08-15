require 'json'
require 'uri'
require 'net/http'

require "bundler/setup"
require 'google-search'
require 'nokogiri'

DUNNO = "I don't understand..."

helpers do
  def parse_text(text, trigger)
    if text
      text.match(/\A#{trigger}\s*(.*)\z/).to_a.last
    end
  end

  def run!(command)
    case command
    when "time"    then Responses.time
    when "bud"     then Responses.bud
    when /weather/ then Responses.weather(command)
    when "cute"    then Responses.cute
    when /insult/  then Responses.insult(command)
    when /joke/    then Responses.joke
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
      in_days = command.match(/in (\d+) days/).to_a.last.to_i
      days_in_query = [7, in_days].compact.min
      url = "http://api.openweathermap.org/data/2.5/forecast/daily?q=#{city}&mode=json&units=metric&cnt=7"
      data = parse_json_url url
      days = data[:list]
      days = days.slice(days_in_query, 1) if in_days
      days
        .map { |day|
          Time.at(day[:dt]).strftime("%a") + ": #{day[:temp][:day]}C"
        }
        .join("\n")
    end

    def joke
      joke_links = "p+ font a"
      base = "http://www.randomjoke.com"
      doc  = get_doc_from_url("http://www.randomjoke.com/topiclist.html")
      joke_links = doc.css(joke_links).map { |link| link[:href] }
      joke_page  = get_doc_from_url("%s/%s" % [base, joke_links.sample])
      joke_lines = joke_page
                     .css("blockquote , br~ p+ p")
                     .map { |p| p.text if p }
                     .compact
      # this is because the site's html is from the 90's
      if joke_lines.size == 2
        joke_lines = joke_lines.reverse
      end
      joke_lines
        .join("\n")
        .strip
    end

    def cute
      url    = "http://www.reddit.com/r/Aww/hot.json?page=#{1.upto(6).to_a.sample}"
      data   = parse_json_url(url)
      data[:data][:children]
        .map { |image| image[:data][:url] }
        .select { |link| File.extname(link) == ".jpg" }
        .sample
    end

    def insult(command)
      user = command.split(" ", 2).last
      doc  = get_doc_from_url("http://www.insult-generator.org/")
      text = doc.css('#insult .text').text
      "@#{user} is a #{text}"
    end

    private

    def parse_json_url url
      body = Net::HTTP.get_response(URI(url)).body
      JSON.parse(body, symbolize_names: true)
    end

    def get_doc_from_url uri
      res = Net::HTTP.get_response(URI.parse(uri))
      Nokogiri::HTML(res.body)
    end
  end
end
