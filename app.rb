require 'bundler'
Bundler.require

$:.unshift File.expand_path('./../lib/app', __FILE__)
require 'scrapper'

Json.new.perform