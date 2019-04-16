require 'rubygems'
require 'data_mapper'

## ## ## Setup ## ## ##
# Displays logs (error messages) for debugging.
DataMapper::Logger.new($stdout, :debug)
# Need install dm-sqlite-adapter.
# Uses postgress when on heroku.
if ENV['DATABASE_URL']
    DataMapper::setup(:default, ENV['DATABASE_URL'] || 'postgres://localhost/mydb')
else
    DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/app.db")
end



## ## ## Tables ## ## ##
class Salon
    include DataMapper::Resource

    property :id                , Serial
    property :name              , Text      , required: true
    property :address           , Text      , required: true
    property :phone_number      , Text      , required: true
    property :email             , Text      , format: :email_address
    property :created_at        , DateTime

    has n, :employees
    has n, :administrators
    has n, :services
    has n, :customers
    has n, :appointments
end

class Administrator
    include DataMapper::Resource

    property :id                , Serial
    property :first_name        , Text
    property :middle_name       , Text
    property :last_name         , Text
    property :phone_number      , String    , required: true
    property :emergency_number  , String    , required: true
    property :email             , String    , format: :email_address
    property :pass_code         , String    , required: true, unique_index: true, length: 6
    
end

class Customer
    include DataMapper::Resource

    property :id            , Serial
    property :first_name    , Text      
    property :last_name     , Text
    property :phone_number  , Text      , default: "xxx-xxx-xxxx"
    property :time_in       , DateTime

    belongs_to :salon
    has n, :appointments
end

class Service
    include DataMapper::Resource

    property :id            , Serial
    property :service_name  , Text      , required: true
    property :created_at    , DateTime


    belongs_to :salon
    has n, :employees
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
    property :pass_code         , String    , required: true, unique_index: true, length: 8
    property :created_at        , DateTime
    
    has n, :timesheets
    has n, :appointments
    belongs_to :service
end

class Timesheet  
    include DataMapper::Resource

    property :id                , Serial
    property :created_at        , DateTime
    property :clock_in          , Boolean   , required: true

    belongs_to :employee
end

class Appointment 
    include DataMapper::Resource

    property :id                , Serial
    property :created_at        , DateTime

    belongs_to :customer
    belongs_to :employee
    belongs_to :salon
end

class Status 
    include DataMapper::Resource

    property :id                , Serial 
    property :created_at        , DateTime

    belongs_to :appointment
end

class Queue 
    include DataMapper::Resource

    property :id                , Serial

    belongs_to :customer
    belongs_to :salon 
    belongs_to :status
end


DataMapper.finalize
DataMapper.auto_upgrade!