require 'httparty'
require 'dotenv/load'

class ChatGPT
  include HTTParty
  base_uri 'https://api.openai.com'

  def initialize(api_key: ENV['OPEN_AI_API_KEY'], model: 'gpt-4')
    @api_key = api_key
    @model = model
  end

  def chat(messages)
    headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@api_key}"
    }
    body = {
      'model' => @model,
      'messages' => messages,
      'top_p' => 0.0
    }.to_json

    response = nil
    3.times do
      response = self.class.post('/v1/chat/completions', headers: headers, body: body)
      if response.parsed_response&.dig('id')
        break
      else
        puts response.parsed_response
      end
    end

    response.parsed_response
  end

  def get_response_message(response)
    response['choices'].first['message']['content']
  end
end

# chat_gpt = ChatGPT.new
# messages = [
#   { 'role' => 'system', 'content' => 'You are a helpful assistant.' },
#   { 'role' => 'user', 'content' => 'Who won the World Series in 2020?' },
#   { 'role' => 'assistant', 'content' => 'The Los Angeles Dodgers won the World Series in 2020.' },
#   { 'role' => 'user', 'content' => 'Where was it played?' }
# ]
#
# response = chat_gpt.chat(messages)
# puts response
