#$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

if ENV['CODECLIMATE_REPO_TOKEN'].nil?
  require 'simplecov'
  SimpleCov.start do
    coverage_dir 'tmp/coverage'
  end
else
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require 'w_flow'