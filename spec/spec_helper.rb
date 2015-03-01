require 'rubygems'
require 'bundler/setup'
require "active_support/all"
require 'webmock/rspec'
require_relative "../lib/app.rb"

Bundler.setup("test", :ci)
Bundler.require("test", :ci)

# Load test & support files
Rake::FileList.new("spec/support/**/*.rb").each do |f|
  require File.expand_path(File.join(__FILE__, "../../#{f}"))
end

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
