RSpec.describe 'Chatmunk Chat Engine' do
  describe 'POST /chat/messages' do
    context 'when action is "join"' do
      before(:example) do
        json = {user_id: '1', action: 'join', name: 'Jon Snow'}
        post '/chat/messages', json, {CONTENT_TYPE: 'application/json'}
      end

      it 'responds with 200 status code' do
        expect(last_response.status).to eq 200
      end

      it 'greets user' do
        expect(JSON.parse(last_response.body)).to eq(
          {'messages' => [{'type' => 'text', 'text' => 'Hello, Jon Snow!'}]}
        )
      end
    end

    context 'when action is "message"' do
      context 'when weather question is in right format' do
        before(:example) do
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
        end

        it 'responds with 200 status code' do
          expect(last_response.status).to eq 200
        end

        it 'responds with correct weather info' do
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
        before(:example) do
          json = {user_id: '1', action: 'message', text: 'Is it cloudy?'}
          post '/chat/messages', json, {CONTENT_TYPE: 'application/json'}
        end

        it 'responds with 200 status code' do
          expect(last_response.status).to eq 200
        end

        it 'responds that it does not understand the question' do
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
end
