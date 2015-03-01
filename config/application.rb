require 'yaml'
require 'rubygems'
require 'bundler/setup'

env = ENV["SINATRA_ENV"] || "development"

Bundler.setup(:default, :ci)
Bundler.require(:default, :ci)

Bundler.setup(env, :ci)
Bundler.require(env, :ci)
