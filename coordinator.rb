require './chat_gpt'
require './researcher'
require 'colorize'

class Coordinator
  SAMPLE_QUESTIONS = [
    "What is the probability that Post Malone will get married by Jan 1, 2025?",
    "How many individual pieces of macaroni were manufactured in 2022?",
    "What is the probability that the New York Yankees will win the World Series this year?",
    "What will the price of Bitcoin be on Jan 1, 2024?",
    "How many shovels have been produced in all of human history?",
    "What will the age be of the oldest person alive on Jan 1, 2030?",
    "How many words are spoken in total between all of the videos on YouTube?",
    "How much would it cost in US Dollars to buy a full body sloth costume for an adult?",
  ]
  def initialize
    @question = ""
    while @question.empty?
      puts "Enter a question about a value that can be calculated or estimated (ex: #{SAMPLE_QUESTIONS.sample})".colorize(:light_red)
      print "Question: ".colorize(:red)
      @question = gets.chomp
    end

    @messages = [
      { 'role' => 'system', 'content' => 'You are the world\'s leading scientist looking to make the best possible estimates of answers to questions. While you cannot foresee the future you are able to use the information that is available right now to make estimations about what will happen in the future. You should use whatever knowledge you have to come up with the best possible estimate, and you should always give the best possible estimate you can even if there is little information available. Your estimates should be as specific as possible and give numbers or percentages when those would be useful for answering the problem. Give a specific number and margin of error in an estimate. Be sure to consider all possibilities that could impact the outcome.' },
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
      add_user_message("Are there #{loop_count == 0 ? "any " : "still remaining " }useful pieces of information that I could look up to help make this estimate more accurate (answer with just yes or no)?")
      response = @chat_gpt.chat(@messages)
      new_message = @chat_gpt.get_response_message(response)
      add_assistant_message(new_message)
      break unless new_message.downcase == 'yes'

      add_user_message('What piece of information can I look up to help answer the question? (Describe just one piece of information that I should look up. No explanation is needed.)')
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
