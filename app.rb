require 'sinatra'
require 'sinatra/namespace'
require_relative 'models.rb'
require_relative 'api_authentication.rb'

configure do
    set :public_folder, File.expand_path('../public', __FILE__)
    set :views, File.expand_path('../views', __FILE__)
    set :root, File.dirname(__FILE__)
end

def not_found!
    halt 404, {message: "404, Not found"}.to_json
end

# Routes
get '/' do
    erb :index
end



# API # 
namespace '/api/v1' do
    
end
