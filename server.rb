# server.rb
require 'sinatra'
require 'sinatra/cross_origin'
require 'mongoid'
require './models/tiny_url'
require './models/statistic'
require './serializers/tiny_url_serializer'
require './serializers/statistic_serializer'
require './helpers'
require 'dotenv'

# DB Setup
Mongoid.load! "mongoid.config"

# Load ENV Variables
Dotenv.load('.env')

set :bind, '0.0.0.0'
configure do
  enable :cross_origin
end

before do
  content_type 'application/json'
  set_headers
end

# Endpoints
get '/' do
  response.headers['Location'] = ENV['WEB_CLIENT_URL']
  status 301
end

get '/:id' do |id|
  begin 
    halt_if_not_found!
    # Save Statistic
    statistic = Statistic.new
    statistic.tiny_id = tiny_url.tiny_id
    statistic.date = DateTime.now
    statistic.save!
  rescue => e
    puts "*** error *******"
    puts e.message
    puts "**********"
    status 500
  else
    response.headers['Location'] = tiny_url.url
    status 301
  end
end

get '/statistics/:id' do
  halt_if_not_found!
  statistics = Statistic.aggregate_by_tiny_id(tiny_url.tiny_id)
  result = statistics.map { |data| serialize_statistic(data) }
  {
    tiny_id: tiny_url.tiny_id,
    tiny_url: tiny_url.tiny_url,
    url: tiny_url.url,
    statistics: result
  }.to_json
end

post '/data/shorten' do
  url_to_create = json_params["url"]
  existing_url = TinyUrl.find_by_url(url_to_create)
  unless existing_url.any?
    new_url = TinyUrl.new
    new_url.url = url_to_create
    new_url.tiny_id = SecureRandom.hex(4)
    new_url.tiny_url = "#{base_url}/#{new_url.tiny_id}"
    halt 422, serialize_tiny_url(new_url) unless new_url.save
    serialize_tiny_url(new_url, 0)
  else
    count = Statistic.find_by_tiny_id(existing_url.first.tiny_id).count
    serialize_tiny_url(existing_url.first, count)
  end
end

def set_headers
  response.headers["Allow"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  response.headers["Cache-Control"] = "public, no-cache, no-store, max-age=0, must-revalidate"
  response.headers["Pragma"] = "no-cache"
  response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
end

options "*" do
  set_headers
  200
end