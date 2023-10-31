# Beginner.Codes Ruby Gem

This is the un-official Ruby Gem for the Beginner.Codes Discord server.

## Running Challenge Tests

- Install the package: `gem install beginner.codes`
- Import the test runner: `require 'challenges'`
- Run the tests, passing in the challenge number and your solution function: `test(458, n_differences)`
```ruby
require 'challenges'

def n_differences(nums)
    nil
end  # Your code goes here!!!


test(458, :n_differences)
```
This will handle downloading the necessary challenge test cases and will run them against your code. It will show you which tests failed, what went wrong, and how many tests succeeded.