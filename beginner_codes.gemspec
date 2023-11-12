Gem::Specification.new do |s|
  s.name        = 'beginner.codes'
  s.version     = '0.1.6'
  s.summary     = 'This is the un-official RubyGem for the Beginner.Codes Discord server.'
  s.description = 'This is the un-official RubyGem for the Beginner.Codes Discord server. Test your daily challenge solutions with provided tests automatically to ensure you have a good solution.'
  s.authors     = ['Mr. Robinhood 5','Zech Zimmerman']
  s.homepage    = 'https://github.com/mrrobinhood5/beginner.codes'
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/mrrobinhood5/beginner.codes/issues',
    'changelog_uri' => 'https://github.com/mrrobinhood5/beginner.codes/blob/master/CHANGELOG.md',
    'homepage_uri' => 'https://github.com/mrrobinhood5/beginner.codes',
    'source_code_uri' => 'https://github.com/mrrobinhood5/beginner.codes/tree/master/lib',
  }
  s.email       = 'mrrobinhood5@gmail.com'
  s.files       = %w[lib/challenges.rb README.md CHANGELOG.md]
  s.license     = 'MIT'
  s.required_ruby_version     = '>= 3.2.2'
  s.required_rubygems_version = '>= 3.4.10'
  s.add_runtime_dependency 'pastel', '~>0.8.0'
  s.add_runtime_dependency 'tty-markdown', '~>0.7.2'
end
