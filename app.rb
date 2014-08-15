require 'json'

helpers do
  def parse_for key, str
    str.each_line do |line|
      k, v = line.split("=", 2)
      if k == key
        return v.strip
      end
    end
  end
end

post "/run" do
  dunno = "I don't understand..."
  body   = request.body.read
  puts body
  puts "#" * 50
  puts params.inspect

  trigger = params[:trigger_word] || parse_for("trigger_word", body)
  text = params[:text]            || parse_for("text", body)
  if text
    command = text.match(/\A#{trigger}\s*(.*)\z/).captures.first
    puts text.match(/\A#{trigger}\s*(.*)\z/).captures.first
    if command
      if command =~ /time\?/
        response = Time.now.to_s
      end
    end
  end
  response ||= dunno
  JSON.dump(text: response)
end
