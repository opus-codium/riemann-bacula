# frozen_string_literal: true

require 'riemann/tools/bacula/version'

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

require 'github_changelog_generator/task'

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.user = 'opus-codium'
  config.project = 'riemann-bacula'
  config.exclude_labels = ['skip-changelog']
  config.future_release = "v#{Riemann::Tools::Bacula::VERSION}"
  config.since_tag = 'v1.0.0'
end
