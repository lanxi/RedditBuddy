# Load the Rails application.
require File.expand_path('../application', __FILE__)
require 'net/http'
require 'net/https'
require 'uri'
require 'json'

# Initialize the Rails application.
Rails.application.initialize!
