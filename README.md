# Team COBRA: Nail Salon Kiosk Application

The purpose of this application is to help speed-up the process of sign-ins at nail salon. This application also provides administrators with unique metrics that showcase how their project is doing. 


## gem requirements
```
bundle install
```
## run app
```
ruby app.rb
```

# Sample API calls. 
### execute [https://quiet-coast-67707.herokuapp.com/api/register?salon_passcode=125&name=first salon&address=123 over st.&email=salon@salon.com&phone=125-125-1225] and adjust parameters to create a salon record. 
### execute [https://quiet-coast-67707.herokuapp.com/api/login?salon_passcode=125] to login as the salon that you created.

#### namespace /api/v1/
* get "/salon/all": retrieve all salons
* get "/salon/:id": retrieve salon by id
* get "/salon/:id/employees": retrieve all employees from salon
* post "/salon/:id/employee": create employee record under a salon
* patch "/salon/:id/employee/:emp_id": edit employee by id under a salon
* delete "/salon/:id/employee/:emp_id": remove employee record by id
* get "/salon/:id/administrators": retrieve all admins from a salon
* get "/salon/:id/services": retrieve all of the services offered by a salon
* ... 
###### More under the app.rb \#API\# section.




###### references 
https://github.com/sinatra/sinatra
