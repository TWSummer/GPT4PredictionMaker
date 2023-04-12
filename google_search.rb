require 'httparty'
require 'dotenv/load'

class GoogleSearch
  include HTTParty
  base_uri 'https://customsearch.googleapis.com/customsearch/v1'

  def self.search(query, options = {})
    default_params = {
      key: ENV['GOOGLE_SEARCH_API_KEY'],
      cx: ENV['GOOGLE_PROGRAMMABLE_SEARCH_ENGINE_ID'],
      q: query
    }
    params = default_params.merge(options)
    response = get('', query: params)
    response.parsed_response
  end

  def self.parse_response(response)
    items = response['items']
    result = []
    items.map! do |item|
      item.slice('title', 'htmlTitle', 'link', 'snippet', 'htmlSnippet')
    end[0..5].each_with_index do |item, idx|
      item_result = ["Result ##{idx + 1}"]
      item.each do |k, v|
        item_result << "#{k}: #{v}"
      end
      result << item_result.join("\n")
      result << "\n\n"
    end
    result.join('')
  end
end

# search_query = 'Likelihood of NY Rangers winning the Stanley Cup'
# results = GoogleSearch.search(search_query)
#
# puts GoogleSearch.parse_response(results)
