require 'sinatra'
require 'sinatra/cross_origin'
require 'net/http'

register Sinatra::CrossOrigin

post '/chat/messages' do
  cross_origin

  {
    messages: [
      {
        type: 'text',
        text: 'HELLO!'
      }
    ]
  }.to_json
end
