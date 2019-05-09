require 'sinatra'
require 'sinatra/namespace'
require_relative 'models.rb'
require_relative 'api_authentication.rb'

configure do
    set :public_folder, File.expand_path('../public', __FILE__)
    set :views, File.expand_path('../views', __FILE__)
    set :root, File.dirname(__FILE__)
end


# Fill status table if it's empty. 

# Status.create(
#   :name => "Active",
#   :created_at => Time.now
# )
# Status.create(
#   :name => "Canceled",
#   :created_at => Time.now
# )




# Makes sure the current salon cannot access other salons' information.
def authenticate_salon!
  curr_id = current_salon.id.to_s.strip
  salon_id = params[:id].to_s.strip

  if curr_id != salon_id
    not_allowed!
    return
  end
end
# Makes sure employee being accessed belongs to the current salon.
def authenticate_employee!
  curr_id = current_salon.id.to_s.strip
  @emp = Employee.get(params[:emp_id])
  if @emp
    emp_salonId = @emp.salon_id.to_s.strip

    if curr_id != emp_salonId
      not_allowed!
    end
  else
    not_found!
  end
end





# Status codes.
def not_found!
    halt 404, {"message": "404, Not found"}.to_json
end
def not_allowed! 
  halt 403, {"message": "Request not allowed"}.to_json
end

# Routes
get '/' do
  erb :index
end
get '/salon/signin' do 
  flash[:notice] = "Hooray, Flash is working!"

  erb :"authentication/salonLogin"

end
get '/salon/menu' do 
  signedin_authenticate!

  
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
    s = Salon.get(params["id"].strip)
    if s
      return s.to_json
    else
      not_found!
    end
  end

  # EMPLOYEES
  get "/salon/:id/employees" do
    api_authenticate!
    authenticate_salon!

    salon = Salon.get(params[:id].strip)
    if salon
      employees = salon.employees
    else 
      not_found!
    end
    
    return employees.to_json
  end

  post "/salon/:id/employee" do
    api_authenticate!
    authenticate_salon!

    e = Employee.new
    e.first_name = params['first_name'].strip
    e.middle_name = params['middle_name'].strip if params['middle_name']
    e.last_name = params['last_name'].strip if params['last_name']
    e.email = params['email'].strip
    e.passcode = params['passcode'].strip
    e.role_id = params['role_id'].strip if params['role_id']
    e.salon_id = params['id']
    e.created_at = Time.now
    e.save

  end
  patch "/salon/:id/employee/:emp_id" do 
    api_authenticate!
    authenticate_salon!
    authenticate_employee!

    # @emp comes from authenticate employee. 
    # Didn't want to re-query the database so we use the same @emp global that's alreadyd defined.
    employee = @emp
    if employee
      # Edit parameter depending on parameter passed in.
      employee.first_name = params["first_name"].strip if params["first_name"]
      employee.middle_name = params["middle_name"].strip if params["middle_name"]
      employee.last_name = params["last_name"].strip if params["last_name"]
      employee.phone_number = params["phone"].strip if params["phone"]
      employee.emergency_number = params["emergency_number"].strip if params["emergency_number"]
      employee.email = params["email"].strip if params["email"]
      employee.role_id = params["role_id"].strip if params["role_id"]

      employee.save
    else 
      not_found!
    end
  end
  # Remove employee from database via its ID.
  delete "/salon/:id/employee/:emp_id" do
    api_authenticate!
    authenticate_salon!
    authenticate_employee!
        
    if (@emp == nil)
      not_found!
    else
      @emp.destroy
    end 
  end

  # ADMINISTRATORS
  get "/salon/:id/administrators" do
    api_authenticate!
    authenticate_salon!

    admins = Employee.all(:role_id => 0)
    admins = admins.all(:salon_id => params[:id].strip)
    return admins.to_json
  end

  # SERVICES
  # Return all services offered by a salon.
  get "/salon/:id/services" do
    api_authenticate!
    authenticate_salon!

    services = Service.all(:salon_id => params[:id].strip)
    return services.to_json
  end

  # Create new service object under salon.
  post "/salon/:id/service" do
    api_authenticate!
    authenticate_salon!

    Service.create(
        :service_name => params['service_name'].strip,
        :created_at => Time.now,
        :salon_id => params['id'],
        )
  end
  # Edit salon service.
  patch "/salon/:id/service/:serv_id" do 
    api_authenticate!
    authenticate_salon!

    service = Service.get(params[:serv_id].strip)
    if service
      service.service_name = params['service_name'].strip
      service.created_at = Time.now
      service.save
    else
      not_found!
    end

  end
  # Remove service from salon.
  delete "/salon/:id/service/:serv_id" do
    api_authenticate!
    authenticate_salon!

    s = Service.get(params[:serv_id].strip)

    if (s ==nil)
      not_found!
    else
      s.destroy
    end
    
  end

  # CUSTOMERS
  # Return all salon customers.
  get "/salon/:id/customers" do
    api_authenticate!
    authenticate_salon!

    customers = Customer.all(:salon_id => params[:id].strip)
    if customers
      return customers.to_json
    else
      not_found!
    end
  end

  # Create new customer object.
  post "/salon/:id/customer" do 
    api_authenticate!
    authenticate_salon!

    Customer.create(
        :first_name => params['first_name'].strip,
        :last_name => params['last_name'].strip,
        :phone_number => params['phone_number'].strip,
        :time_in => Time.now,
        :salon_id => params['id'],
    )
  end

  # APPOINTMENTS
  # Return all appintments from salon with :id
  get "/salon/:id/appointments" do
    api_authenticate!
    authenticate_salon!

    emp_id = params['emp_id'].strip

    apps = Appointment.all(:salon_id => params[:id].strip)
    apps = apps.all(:employee_id => emp_id)
    if apps
      apps.to_json
    else
      not_found!
    end
  end
  # Create appointment object for employee and customer.
  # Also creates a Queue object.
  post "/salon/:id/appointment" do
    api_authenticate!
    authenticate_salon!
    authenticate_employee!


    _employee_id = params["emp_id"]
    _customer_id = params["customer_id"]
    _status = params["status"].strip if params['status']

    if _employee_id==nil || _customer_id==nil || _status==nil
      halt 404, {"message": "missing parameters"}.to_json
    end

    employee = @emp
    customer = Customer.get(_customer_id)
    status = Status.first(:name => _status)
    
    # Create Appointment.
    if employee && customer && status
      new_appointment = Appointment.new
      new_appointment.customer_id = customer.id
      new_appointment.employee_id = employee.id
      new_appointment.salon_id = params[:id]
      new_appointment.status_name = _status
      new_appointment.created_at = Time.now
      new_appointment.save

      # Add to Queue.
      new_queue = Queue.new
      new_queue.customer_id = customer.id
      new_queue.employee_id = employee.id
      new_queue.salon_id = params[:id]
      new_queue.status_name = _status
      new_queue.appointment_id = new_appointment.id
      new_queue.save

    else
      not_found!
    end
  end


  # QUEUE
  # Retrieve the queue of the employee where the appointment is active.
  get "/salon/:id/queue" do
    api_authenticate!
    authenticate_salon!

    active_status = "Active"

    queue = Queue.all(:employee_id => params['emp_id'])
    queue = queue.all(:status_name => "Active")

    if queue
      return queue.to_json
    else
      not_found!
    end

  end
  patch "/salon/:id/employee/:emp_id/queue/" do
    api_authenticate!
    authenticate_salon!
    authenticate_employee!

    queue = Queue.get(params["q_id"])
    app = Appointment.get(queue.appointment_id)

    # Edit status name for appointment and queue.
    queue.status_name = params["status"].strip if params["status"]
    app.status_name = params["status"].strip if params["status"]

    # Save
    queue.save
    app.save

  end
    

  

  # TIMESHEETS -----------------------------------------------------------------

  # Return all timesheets for a salon.
  get "/salon/:id/timesheets/all" do
    api_authenticate!
    authenticate_salon!

    salon = Salon.get(params[:id].strip)
    return salon.timesheets.to_json if salon
  end

  # Return all timesheets for employee with employee id.
  get "/salon/:id/timesheet/:emp_id" do
    api_authenticate!
    authenticate_salon!

    employee = Employee.get(params[:emp_id].strip)
    return employee.timesheets.to_json if employee
  end

  # Create timesheet object for employee.
  post "/salon/:id/timesheet/add" do 
    api_authenticate!
    authenticate_salon!
    authenticate_employee!

    timesheet = Timesheet.new
    timesheet.clock_in = params["clock_in"].strip
    timesheet.created_at = Time.now
    timesheet.salon_id = current_salon.id
    timesheet.employee_id = params["emp_id"].strip
    timesheet.save
  end

  # STATUS
  get "/status" do
    api_authenticate!

    status = Status.all()
    return status.to_json
  end
  


end
