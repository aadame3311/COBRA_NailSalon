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

  # RETURN SALON WITH GIVEN ID
  get "/salon/:id" do
    api_authenticate!
      s = Salon.get(params["id"])
      if s
        return s.to_json
      else
        halt 404, {message: "404 Salon Not Found"}.to_json
      end
  end

  get "/salon/:id/employees" do
    api_authenticate!

    employees = Salon.get(params[:id]).employees
    return employees.to_json
  end
  
  post "/salon/:id/employee" do
    api_authenticate!

    Employee.create(
      :first_name => params['first_name'],
      :middle_name => params['middle_name'],
      :last_name => params['last_name'],
      :email => params['email'],
      :passcode => params['passcode'],
      :role_id => params['role_id'],
      :salon_id => params['id'],
      :created_at => Time.now,
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

  #CUSTOMER

  get "/customer/all" do

  end

  get "/customer/:id" do

  end

  get "/customer/:first_name" do

  end

  get "/customer/:last_name" do

  end

  get "/customer/:phone_number" do

  end

  get "/customer/:time_in" do

  end

  get "/customer/:salon_id" do

  end

  #SERVICE

  get "/service/all" do

  end

  get "/service/:id" do

  end

  get "/service/:service_name" do

  end

  get "/service/:created_at" do

  end

  get "/service/:salon_id" do

  end


end
