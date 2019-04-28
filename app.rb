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

  # SALON
  get "/salon/all" do
    api_authenticate!
    
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

  get "/salon/:id/employees" do
    employees = Salon.get(:id).employee
    return employees.to_json
  end
  post "/salon/:id/employee" do
    Employee.create(
      :first_name => params['first_name'],
      :middle_name => params['middle_name'],
      :last_name => params['last_name'],
      :phone_number => params['phone'],
      :emergency_number => params['emergency_number'],
      :email => params['email'],
      :passcode => params['passcode'],
    )
  end

  get "/salon/administrators" do

  end

  get "/salon/services" do

  end

  get "/salon/customers" do

  end

  get "/salon/appointments" do

  end

  # EMPLOYEES 
  get "/employee/:id" do

  end

  get "/employee/:first_name" do

  end

  get "/employee/:middle_name" do

  end

  get "/employee/:last_name" do

  end

  get "/employee/:phone_number" do

  end

  get "/employee/:emergency_number" do

  end

  get "/employee/:email" do

  end

  get "/employee/:pass_code" do

  end

end
