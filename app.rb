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

  #SALON

  get "/salon/all" do
    salon = Salon.all
    return salon.to_json
  end

  get "/salon/:id" do

  end

  get "/salon/:name" do

  end

  get "/salon/:address" do

  end

  get "/salon/:phone_number" do

  end

  get "/salon/:email" do

  end

  get "/salon/:created_at" do

  end

  get "/salon/employees" do

  end

  get "/salon/administrators" do

  end

  get "/salon/services" do

  end

  get "/salon/customers" do

  end

  get "/salon/appointments" do

  end

  #ADMINISTRATOR

  get "/administrator/all" do

  end

  get "/administrator/:id" do

  end

  get "/administrator/:first_name" do

  end

  get "/administrator/:middle_name" do

  end

  get "/administrator/:last_name" do

  end

  get "/administrator/:phone_number" do

  end

  get "/administrator/:emergency_number" do

  end

  get "/administrator/:email" do

  end

  get "/administrator/:pass_code" do

  end

end
