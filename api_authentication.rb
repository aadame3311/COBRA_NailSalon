    
require 'jwt'
require "json"


SECRET_KEY = "lasjdflajsdlfkjasldkfjalksdjflk"

def api_authenticate!
	@api = true
	bearer = request.env["HTTP_AUTHORIZATION"]

	if bearer
		encoded_token = bearer.slice(7..-1)
		begin
		decoded_token = JWT.decode encoded_token, SECRET_KEY, true, { algorithm: 'HS256' }
		salon_id = decoded_token[0]["user_id"]
		@api_user = Salon.get(salon_id)
		rescue JWT::DecodeError
		 	halt 401, 'A valid token must be passed.'
	    rescue JWT::ExpiredSignature
	     	halt 401, 'The token has expired.'
	    rescue JWT::InvalidIssuerError
	    	halt 401, 'The token does not have a valid issuer.'
	    rescue JWT::InvalidIatError
	    	halt 401, 'The token does not have a valid "issued at" time.'
		end
	else
		halt 401, 'A valid token must be passed.'
	end

end

def token user_id
  payload = { user_id: user_id }
  JWT.encode payload, SECRET_KEY, 'HS256'
end

def current_salon
	if @api
		return @api_user
	else
		if(session[:salon_id])
			@salon ||= Salon.first(id: session[:salon_id])
			return @salon
		else
			return nil
		end
	end
end

get "/api/login" do
	salon_passcode = params['salon_passcode']
	if salon_passcode
		salon = Salon.first(passcode: salon_passcode.downcase)

		if(salon && salon.login(salon_passcode))
			content_type :json
			return {token: token(salon.id)}.to_json
		else
			message = "Invalid credentials #{salon_passcode}"
	    	halt 401, {"message": message}.to_json
		end
	else
		message = "Missing salon_passcode parameter"
	    halt 401, {"message": message}.to_json
	end
end

post "/api/register" do
    salon_passcode = params['salon_passcode']
    
	if salon_passcode
		salon = Salon.first(passcode: salon_passcode.downcase)

		if(salon)
            halt 422, {"message": "Salon passcode already exists"}.to_json
        else
            # Create record.
            new_salon = Salon.new
            new_salon.name =  params['name']
			new_salon.address = params['address']
			new_salon.phone_number = params['phone']
            new_salon.email = params['email']
            new_salon.passcode = salon_passcode
            new_salon.created_at = Time.now
            new_salon.save

            return new_salon.to_json
            halt 201, {"message": "Salon successfully registered"}.to_json
		end
	else
        message = "Missing salon passcode"
        halt 400, {"message": message}.to_json
	end
end

get "/api/token_check" do
	api_authenticate!
	return {"message": "Valid Token"}.to_json
end