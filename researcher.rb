require './chat_gpt'
require './google_search'
require './visit_page'
require './summarizer'
require 'colorize'

class Researcher
  def initialize(research_topic, question)
    @messages = [
      { 'role' => 'system', 'content' => "You are a researcher whose job is to search the internet and return information about the topic you are provided. You can search Google for information by responding with \"search:Query\" and you will receive the search result as your response. You are also able to visit a URL by responding with \"visit:URL\". Only one search or page visit can be done at a time, but you should review multiple sources if necessary before providing a response. Once you have completed researching the subject you should respond with what you have discovered." },
      { 'role' => 'user', 'content' => "Please research #{research_topic} for an organization interested in answering #{question}"}
    ]

    @chat_gpt = ChatGPT.new
    @summarizer = Summarizer.new(research_topic)
    @complete = false
  end

  def research
    while !@complete
      response = @chat_gpt.chat(@messages)
      new_message = @chat_gpt.get_response_message(response)
      @messages << { 'role' => 'assistant', 'content' => new_message }
      if new_message.include?('search:')
        query = new_message[(new_message.index('search:') + 7)..-1].strip
        print "Searching for ".colorize(:blue)
        puts query.colorize(:light_blue)
        search_result = GoogleSearch.search(query)
        search_result = GoogleSearch.parse_response(search_result)
        @messages << { 'role' => 'user', 'content' =>  search_result }
      elsif new_message.include?('visit:')
        url = new_message[(new_message.index('visit:') + 6)..-1]
        print "Visiting ".colorize(:magenta)
        puts url.colorize(:light_magenta)
        html_chunks = VisitPage.new(url).fetch
        total_length = html_chunks.map(&:length).inject(&:+)
        puts "Reading #{total_length} characters of text on page".colorize(:white)
        page_result = if total_length < 200_000
          html_chunks.map do |chunk|
            @summarizer.summarize(chunk)
          end.join("\n\n")
        else
          "Unable to view page. HTML content is too long."
        end

        print "Summary of page: ".colorize(:cyan)
        puts page_result.colorize(:light_cyan)
        @messages << { 'role' => 'user', 'content' => page_result }
      else
        @complete = true
      end
    end

    @messages.last['content']
  end
end

# Researcher.new("Post Malone's current relationship status and any public statements about his intentions or plans regarding marriage.").research
