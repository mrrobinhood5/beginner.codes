# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'
require 'colorize'
require 'tty-markdown'

TEST_CASE_URL = 'https://raw.githubusercontent.com/beginner-codes/challenges/main/weekday/test_cases_'
DESCRIPTION_URL = 'https://raw.githubusercontent.com/beginner-codes/challenges/main/weekday/challenge_'

module Status
  SUCCESS = 1
  FAILED = 0
  EXCEPTION = -1
end

# captures the result of the test
class Result
  attr_accessor :got, :status
  attr_reader :index, :expected

  def initialize(index, expected, got = nil, status = Status::SUCCESS)
    @index = index
    @expected = expected
    @got = got
    @status = status
  end
end

# fetches the description from source
def puts_info(challenge, description, examples)
  url = URI(DESCRIPTION_URL + "#{challenge}.md")
  response = Net::HTTP.get(url).force_encoding('UTF-8')
  result = "\n"
  result += response.split('## ').first.gsub("\n\n", "\n")+"\n" if description
  result += response.split('#')[3].gsub("\n\n", "\n").insert(0,'#') if examples
  result = TTY::Markdown.parse(result)
  puts result
end

# fetches the result from the source
def get_tests(challenge)
  uri = URI(TEST_CASE_URL + "#{challenge}.json")
  response = Net::HTTP.get_response(uri)
  raise "Challenge #{challenge} was not found" unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)

end

# parses your functions and checks if it passes
def run_tests(tests, solution_func)
  results = []
  tests.each_with_index do |test_case, index|
    result = Result.new(index, test_case['return'])
    begin
      result.got = if solution_func.is_a?(Proc)
                     solution_func.call(*test_case['args'])
                   else
                     send(solution_func, *test_case['args'])
                   end

    rescue StandardError => e
      result.status = Status::EXCEPTION
      result.got = e
    else
      result.status = Status::FAILED unless result.got.eql?(test_case['return'])
    end
    results << result
  end
  results
end

# displays the results on the terminal
def show_results(challenge, results, total_tests)
  failures = 0
  results.each do |result|
    if result.status.equal?(Status::FAILED)
      puts "Test #{result.index.to_s.blue} failed:  Expected #{result.expected.to_s.green}, got #{result.got.to_s.red}"
      failures += 1
    elsif result.status.equal?(Status::EXCEPTION)
      puts "Test #{result.index} failed:  #{result.got}"
      failures += 1
    end
  end
  puts ' ' if failures
  puts "---- Challenge #{challenge} Results ----".light_yellow.on_black
  puts "#{(total_tests - failures).to_s.green} passed, #{failures.to_s.red} failed"
  puts "\n**** Great job!!! ****".green if failures.zero?
end

# the main entry point function
def test(challenge, solution_func, description: false, examples: false)
  tests = get_tests(challenge)
  puts_info(challenge, description, examples) if description || examples
  results = run_tests(tests, solution_func)
  show_results(challenge, results, tests.size)
end
