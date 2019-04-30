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
        not_found!
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
  # Remove employee from database via its ID.
  delete "/salon/:id/employee/:emp_id" do
    api_authenticate!
    e = Employee.get(params["emp_id"])
    
    if (e ==nil)
      not_found!
    end

    if (current_salon.id == e.salon_id)
      e.destroy
    else
      halt 401, {message: "401 Action Not Allowed"}.to_json
    end  
  end

  # ADMINISTRATORS
  get "/salon/:id/administrators" do
    api_authenticate!

    admins = Employee.all(:role_id => 0)
    return admins.to_json
  end

  # SERVICES
  # Return all services offered by a salon.
  get "/salon/:id/services" do
    api_authenticate!

    services = Service.all(:salon_id => params[:id])
    return services.to_json
  end

  # Create new service object under salon.
  post "/salon/:id/service" do
    api_authenticate!

    Service.create(
        :service_name => params['service_name'],
        :created_at => Time.now,
        :salon_id => params['id'],
        )
  end
  # Edit salon service.
  patch "/salon/:id/service/:serv_id" do 
    api_authenticate!

    # Make sure the employee belongs to the salon calling the route.
    if params[:id]==current_salon.id
      service = Service.get(params[:serv_id])

      # Edit parameter depending on parameter passed in.
      service.service_name = params["service_name"] if params["service_name"]

      service.save
    else
      not_allowed!
    end

  end
  # Remove service from salon.
  delete "/salon/:id/service/:serv_id" do
    api_authenticate!

    s = Service.get(params["serv_id"])

    if (s ==nil)
      not_found!
    end

    if (current_salon.id == s.salon_id)
      s.destroy
    else
      halt 401, {message: "401 Action Not Allowed"}.to_json
    end
  end

  # CUSTOMERS
  # Return all salon customers.
  get "/salon/:id/customers" do
    api_authenticate!

    customers = Customer.all(:salon_id => params[:id])
    return customers.to_json
  end

  # Create new customer object.
  post "/salon/:id/customer" do 
    api_authenticate!

    Customer.create(
        :first_name => params['first_name'],
        :last_name => params['last_name'],
        :phone_number => params['phone_number'],
        :time_in => Time.now,
        :salon_id => params['id'],
        )
  end

  # APPOINTMENTS
  # Return all appointments from salon with :id
  get "/salon/:id/appointments" do
    api_authenticate!

    appointments = Appointment.all(:salon_id => params[:id])
    return appointments.to_json
  end

  # Create appointment object for employee and customer.
  # Also creates a Queue object.
  post "/salon/:id/appointment/:emp_id/:cust_id/:status_id" do
    api_authenticate!

    if params[:id] == current_salon.id
      employee = Employee.get(params[:emp_id])
      customer = Customer.get(params[:cust_id])
      # Checks if employee works for salon. Checks if customer is customer of salon.
      if current_salon.id == employee.salon_id && current_salon.id == customer.salon_id
        new_appointment = Appointment.new
        new_appointment.customer_id = customer.id
        new_appointment.employee_id = employee.id
        new_appointment.salon_id = params[:id]
        new_appointment.status_id = params[:status_id]
        new_appointment.save

        # Create queue object based of appointment and status.
        new_queue = Queue.new
        new_queue.customer_id = customer.id
        new_queue.salon_id = params[:id]
        new_queue.status_id = params[:status_id]
        new_queue.appointment_id = new_appointment.id
        new_queue.save
      end
    else
      not_allowed!
    end

  end

  # TIMESHEETS 
  # Return all timesheets for a salon.
  get "/salon/:id/timesheets/all" do
    api_authenticate!

    if params[:id]==current_salon.id
      salon = Salon.get(params[:id])
      return salon.timesheets.to_json if salon

      not_found!
    else
      not_allowed!
    end
  end
  # Return all timesheets for employee with employee id.
  get "/salon/:id/timesheet/:emp_id" do
    api_authenticate!

    if params[:id]==current_salon.id
      employee = Employee.get(params[:emp_id])
      return employee.timesheets.to_json if employee
    else
      not_allowed!
    end
  end
  # Create timesheet object for employee.
  post "/salon/:id/timesheet/:emp_id" do 
  end



end
