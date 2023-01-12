# frozen_string_literal: true

require_relative 'lib/faraday/xml/version'

Gem::Specification.new do |spec|
  spec.name = 'faraday-xml'
  spec.version = Faraday::XML::VERSION
  spec.authors = ['Benjamin Fleischer']
  spec.email = ['github@benjaminfleischer.com']

  spec.summary = 'Faraday XML Middleware'
  spec.description = <<~DESC
    Faraday XML Middleware.
  DESC
  spec.license = 'MIT'

  github_uri = "https://github.com/gemhome/#{spec.name}"

  spec.homepage = github_uri

  spec.metadata = {
    'bug_tracker_uri' => "#{github_uri}/issues",
    'changelog_uri' => "#{github_uri}/blob/v#{spec.version}/CHANGELOG.md",
    'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => github_uri,
    'wiki_uri' => "#{github_uri}/wiki"
  }

  spec.files = Dir['lib/**/*', 'README.md', 'LICENSE.md', 'CHANGELOG.md']

  spec.required_ruby_version = '>= 2.6', '< 4'

  spec.add_runtime_dependency 'faraday', '>= 1.10', '< 3'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.21.0'

  spec.add_development_dependency 'rubocop', '~> 1.31.0'
  spec.add_development_dependency 'rubocop-packaging', '~> 0.5.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.0'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.0'
end
