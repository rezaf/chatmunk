RSpec.describe 'Chatmunk Chat Engine' do
  include Rack::Test::Methods

  context 'when action is to join' do
    it 'greets user' do
      json = {user_id: '1', action: 'join', name: 'Jon Snow'}

      post '/chat/messages', json, {CONTENT_TYPE: 'application/json'}

      expect(JSON.parse(last_response.body)).to eq(
        {'messages' => [{'type' => 'text', 'text' => 'Hello, Jon Snow!'}]}
      )
    end
  end

  context 'when action is message' do
    context 'when weather question is in right format' do
      it 'responds with correct weather info' do
        stub_request(
          :get,
          /maps\.googleapis\.com\/maps\/api\/geocode\/json\?address=SF/
        ).to_return(
          status: 200,
          body: {
            "results" => [
              {
                "geometry" => {
                  "location" => { "lat" => 37.7749295, "lng" => -122.4194155 }
                }
              }
            ]
          }.to_json
        )

        stub_request(
          :get,
          /api\.darksky\.net\/forecast\/.+\/37\.7749295,-122\.4194155/
        ).to_return(
          status: 200,
          body: {
            "currently" => {
              "summary" => "Mostly Cloudy",
              "temperature" => 58.29
            }
          }.to_json
        )

        json = {user_id: '1', action: 'message', text: 'SF weather'}

        post '/chat/messages', json, {CONTENT_TYPE: 'application/json'}

        expect(JSON.parse(last_response.body)).to eq(
          {
            'messages' => [
              {
                'type' => 'text',
                'text' => 'Currently it is 58.29F. Mostly Cloudy'
              }
            ]
          }
        )
      end
    end

    context 'when question is not in right format' do
      it 'responds that it does not understand the question' do
        json = {user_id: '1', action: 'message', text: 'Is it cloudy outside?'}

        post '/chat/messages', json, {CONTENT_TYPE: 'application/json'}

        expect(JSON.parse(last_response.body)).to eq(
          {
            'messages' => [
              {
                'type' => 'text',
                'text' => 'Hmm, I am not sure if I understand this question.'
              }
            ]
          }
        )
      end
    end
  end
end
