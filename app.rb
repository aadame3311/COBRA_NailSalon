require 'sinatra'
require 'sinatra/namespace'
require_relative 'models.rb'
require_relative 'api_authentication.rb'

configure do
    set :public_folder, File.expand_path('../public', __FILE__)
    set :views, File.expand_path('../views', __FILE__)
    set :root, File.dirname(__FILE__)
end

# Status codes.
def not_found!
    halt 404, {message: "404, Not found"}.to_json
end
def not_allowed! 
  halt 403, {"message": "Request not allowed"}.to_json
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

  # EMPLOYEES
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
  patch "/salon/:id/employee/:emp_id" do 
    api_authenticate!

    # Make sure the employee belongs to the salon calling the route.
    if params[:id]==current_salon.id
      employee = Employee.get(params[:emp_id])

      # Edit parameter depending on parameter passed in.
      employee.first_name = params["first_name"] if params["first_name"]
      employee.middle_name = params["middle_name"] if params["middle_name"]
      employee.last_name = params["last_name"] if params["last_name"]
      employee.phone_number = params["phone"] if params["phone"]
      employee.emergency_number = params["emergency_number"] if params["emergency_number"]
      employee.email = params["email"] if params["email"]
      employee.role_id = params["role_id"] if params["role_id"]

      employee.save
    else 
      not_allowed!
    end
  end

  # ADMINISTRATORS
  get "/salon/:id/administrators" do
    api_authenticate!

    admins = Employee.all(:role_id => 0)
    return admins.to_json
  end

  # SERVICES
  get "/salon/:id/services" do
    api_authenticate!

  end
  post "/salon/:id/service" do
    api_authenticate!

  end
  patch "/salon/:id/service/:serv_id" do 
    api_authenticate!

  end
  delete "/salon/:id/service/:serv_id" do
    api_authenticate!

  end

  # CUSTOMERS
  get "/salon/:id/customers" do
    api_authenticate!

  end
  post "/salon/:id/customer" do 
    api_authenticate!

  end

  # APPOINTMENTS
  get "/salon/:id/appointments" do
    api_authenticate!

  end
  post "/salon/:id/appointment" do
    api_authenticate!

  end
  delete "/salon/:id/appointment/:app_id" do
    api_authenticate!

  end

  # TIMESHEETS 
  get "/salon/:id/timesheets/all" do
    api_authenticate!

    if params[:id]==current_salon.id
      timesheets = Timesheet.all(:salon_id => params[:id])
    else
      not_allowed!
    end
  end
  get "/salon/:id/timesheet/:emp_id" do
    api_authenticate!

    if params[:id]==current_salon.id
      timesheet = Timesheet.all(:employee_id => params[:emp_id])
      return timesheet.to_json if timesheet
    else
      not_allowed!
    end
  end


end
