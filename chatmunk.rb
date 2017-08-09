# Require dependencies
require 'sinatra'
require 'sinatra/cross_origin'
require 'net/http'
require 'dotenv'

# Register the cross origin extension
register Sinatra::CrossOrigin

# Set default application port to 9000
set :port, 9000

# Load keys from .env file
Dotenv.load

# URL's for Google Maps Geocoding and Dark Sky
GMAPS_URL = 'https://maps.googleapis.com/maps/api/geocode/json'
DARKSKY_URL = 'https://api.darksky.net/forecast'

# Expose /chat/messages route for post requests
post '/chat/messages' do

  # Allow cross origin requests on this route
  cross_origin

  # Determine response text based on chat action
  response_text =
    if params[:action] == 'join'
      "Hello, #{params[:name]}!"
    else
      parse_question
    end

  # Respond with JSON message
  {
    messages: [
      {
        type: 'text',
        text: response_text
      }
    ]
  }.to_json
end

# Parse question text, and form appropriate response
# @return [String]
def parse_question
  question = params[:text]

  # Extract address from message
  address =
    if question[0..20]&.downcase == "what's the weather in"
      question[21..-1]
    elsif question[0..9]&.downcase == 'weather in'
      question[10..-1]
    elsif question[-7..-1]&.downcase == 'weather'
      question[0..-8]
    else
      ''
    end.strip

  # Return current weather or let user know we cannot determine address
  if address.empty?
    'Hmm, I am not sure if I understand this question.'
  else
    weather(address)
  end
end

# Determine current weather for given address
# @param address [String]
# @return [String]
def weather(address)
  # Get latitude and longitude for address from Google Maps
  gmaps = URI.parse("#{GMAPS_URL}?address=#{address}&key=#{ENV['GMAPS_KEY']}")
  gmaps_response = JSON.parse(Net::HTTP.get(gmaps))
  location = gmaps_response['results'][0]['geometry']['location']
  lat = location['lat']
  lng = location['lng']

  # Get current weather from Dark Sky for latitude and longitude
  darksky = URI.parse("#{DARKSKY_URL}/#{ENV['DARKSKY_KEY']}/#{lat},#{lng}")
  darksky_response = JSON.parse(Net::HTTP.get(darksky))
  current_weather = darksky_response['currently']
  temperature = current_weather['temperature']
  summary = current_weather['summary']

  # Return string with current weather information
  "Currently it is #{temperature}F. #{summary}"
end
