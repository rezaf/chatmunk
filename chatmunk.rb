require 'sinatra'
require 'sinatra/cross_origin'
require 'net/http'

register Sinatra::CrossOrigin

post '/chat/messages' do
  cross_origin

  response_text =
    if params[:action] == 'join'
      "Hello, #{params[:name]}!"
    else
      "In progress."
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
