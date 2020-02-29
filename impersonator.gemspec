lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'impersonator/version'

Gem::Specification.new do |spec|
  spec.name          = 'impersonator'
  spec.version       = Impersonator::VERSION
  spec.authors       = ['Jorge Manrubia']
  spec.email         = ['jorge.manrubia@gmail.com']

  spec.summary       = 'Generate test stubs that replay recorded interactions'
  spec.description   = 'Record and replay object interactions. Ideal for mocking not-http services'\
                       ' when testing (just because, for http, VCR is probably what you want)'
  spec.homepage      = 'https://github.com/jorgemanrubia/impersonator'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/jorgemanrubia/impersonator'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'zeitwerk', '~> 2.1.6'
  spec.add_development_dependency 'bundler', '~> 1.17'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter'
end
