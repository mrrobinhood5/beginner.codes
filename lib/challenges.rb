# frozen_string_literal: true
# TODO: use a latest: arg to bring up the last test

require 'json'
require 'uri'
require 'net/http'
require 'pastel'
require 'tty-markdown'
require 'tty-table'


USAGE = '# **USAGE**
```py
test(challenge: int, your_function: :func, description: bool, examples: bool)
---
test(458, :your_function)   # runs all tests cases on your function
test(458, :your_function, description: true)  # adds the test description in the terminal
test(458, :your_function, examples: true)  # adds test examples in the terminal
test(458, :your_function, true, true)  # adds both description and examples
test(458, description: true)  # prints only description without running tests
test(458, examples: true)  # same as above but with examples```'

module Status
  SUCCESS = 1
  FAILED = 0
  EXCEPTION = -1
end

# passes the colors to the terminal
class Colors
  def initialize
    @pastel = Pastel.new
  end

  def respond_to_missing?(name, include_private = false)
    !name.to_s.empty? || super
  end

  def method_missing(name, *args)
    if respond_to_missing?(name)
      @pastel.send(name, *args)
    else
      @pastel.send(:white, *args)
    end
  end
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

def make_table(rows)
  c = Colors.new
  header = [c.blue('#:'), c.green('Expected:'), c.red('Got:')]
  rows = rows.map do |row|
    [c.blue(row[0]), c.green(row[1]), c.red(row[2])]
  end
  TTY::Table.new(header, [*rows])
end

def fetch_data(url)
  Net::HTTP.get(URI(url)).force_encoding('UTF-8')
end

# fetches the result from the source
def get_tests(challenge)
  url = "https://raw.githubusercontent.com/beginner-codes/challenges/main/weekday/test_cases_#{challenge}.json"
  begin
    JSON.parse(fetch_data(url))
  rescue RuntimeError => e
    e
  end

end

# fetches the description from source
def get_info(challenge, description, examples)
  url = "https://raw.githubusercontent.com/beginner-codes/challenges/main/weekday/challenge_#{challenge}.md"
  result = ''

  begin
    info = fetch_data(url)
    result += info.split('## ').first.gsub("\n\n", "\n") << "\n" if description
    result += info.split('#')[3].gsub("\n\n", "\n").insert(0,'#') if examples
  rescue IndexError || RuntimeError => e
    result += e
  end
  TTY::Markdown.parse(result + '***')
end

# parses your functions and checks if it passes
def run_tests(tests, solution_func)
  results = []
  tests.each_with_index do |test_case, index|
    result = Result.new(index, test_case['return'])
    begin
      result.got = solution_func.is_a?(Proc) ? solution_func.call(*test_case['args']) : send(solution_func, *test_case['args'])
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
def show_results(challenge, results, total_tests, info)
  puts info
  c = Colors.new
  rows = []
  failures = 0
  results.each do |result|
    next unless result.status.equal?(Status::FAILED) or result.status.equal?(Status::EXCEPTION)

    rows << [result.index, result.expected.inspect, result.got]
    failures += 1
  end

  table = make_table(rows)
  puts table.render(:unicode, alignment: %i[right left left]) if failures
  return if results == []

  puts c.yellow("---- Challenge #{challenge} Results ----")
  puts "#{c.green(total_tests - failures)} passed, #{c.red(failures)} failed"
  puts c.green("\n**** Great job!!! ****") if failures.zero?
end

# the main entry point function
def test(challenge = nil, solution_func = nil, description: false, examples: false)
  if solution_func
    tests = get_tests(challenge)
    results = run_tests(tests, solution_func) unless tests.kind_of? RuntimeError
  else
    tests = []
    results = []
  end
  info = if solution_func || examples || description || challenge
           get_info(challenge, description, examples)
         else
           TTY::Markdown.parse(USAGE)
         end
  show_results(challenge, results, tests.size, info)
end
