require 'json'

post "/run" do

  JSON.dump(text: Time.now.to_s)
end
