# frozen_string_literal: true

require 'json'
require 'uri'
require 'net/http'

# this gets imported to your file

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


def get_tests(challenge)
  uri = URI("https://raw.githubusercontent.com/beginner-codes/challenges/main/weekday/test_cases_#{challenge}.json")
  # uri = URI("https://raw.githubusercontent.com/beginner-codes/challenges/bfb59fe9fbec461a33cc80b20d1d976e9095853c/weekday/test_cases_#{challenge}.json")
  response = Net::HTTP.get_response(uri)
  raise "Challenge #{challenge} was not found" unless response.is_a?(Net::HTTPSuccess)

  JSON.parse(response.body)

end

def run_tests(tests, solution_func)
  results = []
  tests.each_with_index do |test_case, index|
    result = Result.new(index, test_case['return'])
    begin
      result.got = send(solution_func, *test_case['args'])
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

def show_results(challenge, results, total_tests)
  failures = 0
  results.each do |result|
    if result.status.equal?(Status::FAILED)
      puts "Test #{result.index} failed:  Expected #{result.expected}, got #{result.got}."
      failures += 1
    elsif result.status.equal?(Status::EXCEPTION)
      puts "Test #{result.index} failed:  #{result.got}"
      failures += 1
    end
  end
  puts ' ' if failures
  puts "---- Challenge #{challenge} Results ----"
  puts "#{total_tests - failures} passed, #{failures} failed"
  puts "\n**** Great job!!! ****" if failures.zero?
end

def test(challenge, solution_func)
  tests = get_tests(challenge)
  results = run_tests(tests, solution_func)
  show_results(challenge, results, tests.size)
end
