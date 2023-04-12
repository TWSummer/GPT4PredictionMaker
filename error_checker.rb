require './chat_gpt'

class ErrorChecker
  def initialize(question)
    @messages = [
      { 'role' => 'system', 'content' => "You are a teacher grading a student's answer to the question \"#{question}\". Check the student's text for mistakes in logic, math, and unit conversion and respond with a corrected answer and the corrected reasoning to support it only if there are mistakes made. If the logic is correct respond by simply saying that it is correct. Be EXTRA CAREFUL to not introduce new mistakes." },
    ]

    @chat_gpt = ChatGPT.new
  end

  def check_errors(text)
    messages = @messages.dup
    messages << { 'role' => 'user', 'content' => text.to_s }
    response = @chat_gpt.chat(messages)
    puts response
    @chat_gpt.get_response_message(response)
  end
end

# puts ErrorChecker.new('If all toothpicks manufactured in 2022 were stacked end to end, how many times could they circle the earth?').check_errors("The global toothpick market was valued at USD 2.2 billion in 2021. To estimate the number of toothpicks produced in 2022, we can use the projected CAGR of 7.5% for the forecast period (2021-2030).
#
# First, let's calculate the estimated market size for 2022:
#
# Market size in 2022 = Market size in 2021 * (1 + CAGR)
# Market size in 2022 = 2.2 billion * (1 + 0.075)
# Market size in 2022 = 2.365 billion USD
#
# Now, we need to estimate the average cost of a toothpick to determine the number of toothpicks produced. Since there is no specific information available on the average cost of a toothpick, we can make an assumption. Let's assume the average cost of a toothpick is $0.001 (one-tenth of a cent).
#
# Number of toothpicks produced in 2022 = Market size in 2022 / Average cost of a toothpick
# Number of toothpicks produced in 2022 = 2.365 billion / 0.001
# Number of toothpicks produced in 2022 = 2.365 trillion
#
# Next, we need to find the length of a toothpick. The average length of a toothpick is about 6.5 cm (2.56 inches).
#
# Total length of toothpicks produced in 2022 = Number of toothpicks produced * Length of a toothpick
# Total length of toothpicks produced in 2022 = 2.365 trillion * 6.5 cm
# Total length of toothpicks produced in 2022 = 15.3725 trillion cm
#
# Now, let's convert the total length of toothpicks to kilometers:
#
# Total length of toothpicks produced in 2022 (in km) = 15.3725 trillion cm / 100,000 (1 km = 100,000 cm)
# Total length of toothpicks produced in 2022 (in km) = 153,725,000 km
#
# The Earth's circumference is approximately 40,075 km. To find out how many times the toothpicks could circle the Earth, we can divide the total length of toothpicks by the Earth's circumference:
#
# Number of times toothpicks could circle the Earth = Total length of toothpicks (in km) / Earth's circumference (in km)
# Number of times toothpicks could circle the Earth = 153,725,000 km / 40,075 km
# Number of times toothpicks could circle the Earth ≈ 3,834
#
# If all toothpicks manufactured in 2022 were stacked end to end, they could circle the Earth approximately 3,834 times. This estimation is based on the assumption of the average cost of a toothpick and the projected growth rate of the toothpick market.")
