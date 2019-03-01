# frozen_string_literal: true

require File.expand_path(
  File.join('..', 'lib', 'omniauth', 'atlassian_oauth2', 'version'),
  __FILE__
)

Gem::Specification.new do |gem|
  gem.name          = 'omniauth-atlassian-oauth2'
  gem.version       = OmniAuth::AtlassianOauth2::VERSION
  gem.license       = 'MIT'
  gem.summary       = %(An Atlassian OAuth2 strategy for OmniAuth 1.x)
  gem.description   = %(An Atlassian OAuth2 strategy for OmniAuth 1.x. This allows you to login to Atlassian with your ruby app.)
  gem.authors       = ['Ben Standefer']
  gem.email         = ['benstandefer@gmail.com']
  gem.homepage      = 'https://github.com/aguynamedben/omniauth-atlassian-oauth2'

  gem.files         = `git ls-files`.split("\n")
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.1'

  gem.add_runtime_dependency 'omniauth', '>= 1.1.1'
  gem.add_runtime_dependency 'omniauth-oauth2', '>= 1.5'

  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'rspec', '~> 3.6'
  gem.add_development_dependency 'rubocop', '~> 0.49'
end
