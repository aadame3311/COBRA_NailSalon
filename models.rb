require 'rubygems'
require 'data_mapper'

## ## ## Setup ## ## ##
# Displays logs (error messages) for debugging.
DataMapper::Logger.new($stdout, :debug)
DataMapper::Model.raise_on_save_failure = true  # globally across all models
# Need install dm-sqlite-adapter.
# Uses postgress when on heroku.
if ENV['DATABASE_URL']
    DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end

## ## ## Tables ## ## ##


class Customer
    include DataMapper::Resource

    property :id            , Serial
    property :first_name    , Text      
    property :last_name     , Text
    property :phone_number  , Text      , default: "xxx-xxx-xxxx"
    property :time_in       , DateTime

    property :salon_id      , Integer

    ## Relations.
    def appointments
        return Appointment.all(:customer_id=>self.id)
    end
end

class Service
    include DataMapper::Resource

    property :id            , Serial
    property :service_name  , Text      , required: true
    property :created_at    , DateTime

    property :salon_id      , Integer


    ## Relations.
    def employee
        return Employee.all(:service_id=>self.id)
    end
end

class Employee
    include DataMapper::Resource

    property :id                , Serial    
    property :first_name        , Text
    property :middle_name       , Text
    property :last_name         , Text
    property :phone_number      , String    , required: true
    property :emergency_number  , String    , required: true
    property :email             , String    , format: :email_address
    property :passcode         , String    , required: true, unique_index: true, length: 8, default: '000'
    property :created_at        , DateTime
    # 1 = employee
    # 0 = administrator
    property :role_id           , Integer   , default: 1
    
    property :salon             , Integer


    ## Relations.
    def timesheets
        return Timesheet.all(:employee_id=>self.id)
    end
    def appointments
        return Appointment.all(:employee_id=>self.id)
    end
end

class Timesheet  
    include DataMapper::Resource

    property :id                , Serial
    property :created_at        , DateTime
    property :clock_in          , Boolean   , required: true

    property :employee_id       , Integer
end

class Appointment 
    include DataMapper::Resource

    property :id                , Serial
    property :created_at        , DateTime

    property :customer_id       , Integer
    property :employee_id       , Integer
    property :salon_id          , Integer
end

class Status 
    include DataMapper::Resource

    property :id                , Serial 
    property :created_at        , DateTime
    property :appointment_id    , Integer
end

class Queue 
    include DataMapper::Resource

    property :id                , Serial
    property :customer_id       , Integer
    property :salon_id          , Integer
    property :status_id         , Integer
end
class Salon
    include DataMapper::Resource

    property :id                , Serial
    property :name              , Text      , required: true
    property :address           , Text      , required: true
    property :phone_number      , Text      , required: true    , default: '000-000-0000'
    property :email             , Text      , format: :email_address
    property :passcode          , Text      , required: true    , default: '000'
    property :created_at        , DateTime

    
    ## Relations.
    def employees
        return Employee.all(:salon_id=>self.id)
    end
    def services 
        return Service.all(:salon_id=>self.id)
    end
    def customers
        return Customer.all(:salon_id=>self.id)
    end
    def appointments
        return Appointment.all(:salon_id=>self.id)
    end


    def login(salon_passcode)
        return self.passcode == salon_passcode
    end
end

DataMapper.finalize

Salon.auto_upgrade!
Queue.auto_upgrade!
Status.auto_upgrade!
Appointment.auto_upgrade!
Timesheet.auto_upgrade!
Employee.auto_upgrade!
Service.auto_upgrade!
Customer.auto_upgrade!


## UNCOMMENT WHEN TABLES ARE DRASTICALLY CHANGED OR ADDED ##
### WILL WIPE DATABASE ###

# Salon.auto_migrate!
# Queue.auto_migrate!
# Status.auto_migrate!
# Appointment.auto_migrate!
# Timesheet.auto_migrate!
# Employee.auto_migrate!
# Service.auto_migrate!
# Customer.auto_migrate!