require './chat_gpt'
require './researcher'
require 'colorize'

class Coordinator
  def initialize
    @question = ""
    while @question.empty?
      puts "Enter a question about a value that can be calculated or estimated (ex: What is the probability that Post Malone will get married by Jan 1, 2025?)".colorize(:light_red)
      print "Question: ".colorize(:red)
      @question = gets.chomp
    end

    @messages = [
      { 'role' => 'system', 'content' => 'You are a helpful assistant that attempts to make the best possible estimates of answers to questions. While you cannot foresee the future you are able to use the information that is available right now to make estimations about what will happen in the future. You should use whatever knowledge you have to come up with the best possible estimate, and you should always give the best possible estimate you can even if there is little information available. Your estimates should be as specific as possible and give numbers or percentages when those would be useful for answering the problem. Give a specific number and margin of error in an estimate.' },
      { 'role' => 'user', 'content' =>  @question},
    ]

    @chat_gpt = ChatGPT.new
  end

  def run
    response = @chat_gpt.chat(@messages)
    new_message = @chat_gpt.get_response_message(response)
    add_assistant_message(new_message)

    loop_count = 0
    while loop_count < 15
      add_user_message("Are there any #{loop_count == 0 ? "" : "other " }useful pieces of information that I could look up to help make this estimate more accurate (answer with just yes or no)?")
      response = @chat_gpt.chat(@messages)
      new_message = @chat_gpt.get_response_message(response)
      add_assistant_message(new_message)
      break unless new_message.downcase == 'yes'

      add_user_message('What piece of information can I look up to help answer the question? (Describe just the information that should be looked up. No explanation is needed.)')
      response = @chat_gpt.chat(@messages)
      new_message = @chat_gpt.get_response_message(response)
      add_assistant_message(new_message)
      research = Researcher.new(new_message, @question).research
      add_user_message("Here is what I was able to uncover:\n\n#{research}")
      response = @chat_gpt.chat(@messages)
      new_message = @chat_gpt.get_response_message(response)
      add_assistant_message(new_message)

      loop_count += 1
    end

    while true
      puts "Enter a message for the assistant (leave blank to exit):".colorize(:red)
      message = gets.chomp
      break if message.empty?

      add_user_message(message)
      response = @chat_gpt.chat(@messages)
      puts response
      new_message = @chat_gpt.get_response_message(response)
      add_assistant_message(new_message)
    end
  end

  def add_assistant_message(message)
    print "Assistant: ".colorize(:yellow)
    puts message.colorize(:light_yellow)
    @messages << { 'role' => 'assistant', 'content' => message }
  end

  def add_user_message(message)
    print "User: ".colorize(:green)
    puts message.colorize(:light_green)
    @messages << { 'role' => 'user', 'content' => message }
  end
end
