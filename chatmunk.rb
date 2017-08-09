require 'sinatra'
require 'sinatra/cross_origin'
require 'net/http'
require 'dotenv'

register Sinatra::CrossOrigin
set :port, 9000
Dotenv.load

GMAPS_URL = 'https://maps.googleapis.com/maps/api/geocode/json'
DARKSKY_URL = 'https://api.darksky.net/forecast'

post '/chat/messages' do
  cross_origin

  response_text =
    if params[:action] == 'join'
      "Hello, #{params[:name]}!"
    else
      parse_question
    end

  {
    messages: [
      {
        type: 'text',
        text: response_text
      }
    ]
  }.to_json
end

def parse_question
  question = params[:text]

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

  if address.empty?
    'Hmm, I am not sure if I understand this question.'
  else
    weather(address)
  end
end

def weather(address)
  gmaps = URI.parse("#{GMAPS_URL}?address=#{address}&key=#{ENV['GMAPS_KEY']}")
  gmaps_response = JSON.parse(Net::HTTP.get(gmaps))
  location = gmaps_response['results'][0]['geometry']['location']
  lat = location['lat']
  lng = location['lng']

  darksky = URI.parse("#{DARKSKY_URL}/#{ENV['DARKSKY_KEY']}/#{lat},#{lng}")
  darksky_response = JSON.parse(Net::HTTP.get(darksky))
  current_weather = darksky_response['currently']
  temperature = current_weather['temperature']
  summary = current_weather['summary']

  "Currently it is #{temperature}F. #{summary}"
end
