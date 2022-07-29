# frozen_string_literal: true

require 'riemann/tools/bacula/version'

require 'bundler/gem_tasks'

require 'github_changelog_generator/task'

GitHubChangelogGenerator::RakeTask.new :changelog do |config|
  config.user = 'opus-codium'
  config.project = 'riemann-bacula'
  config.exclude_labels = ['skip-changelog']
  config.future_release = Riemann::Tools::Bacula::VERSION
end
