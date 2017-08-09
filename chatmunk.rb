require 'sinatra'
require 'sinatra/cross_origin'
require 'net/http'

register Sinatra::CrossOrigin
set :port, 9000

GMAPS_URL = 'https://maps.googleapis.com/maps/api/geocode/json'

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
  gmaps = URI.parse("#{g_url}?address=#{address}&key=#{ENV['GMAPS_KEY']}")
  gmaps_response = JSON.parse(Net::HTTP.get(gmaps))
  location = gmaps_response['results'][0]['geometry']['location']
  lat = location['lat']
  lng = location['lng']

  'In progress!'
end
