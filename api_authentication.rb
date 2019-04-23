require "json"
require "jwt"

SECRET_KEY = "lkhalkjelqkjfnasdkjju"

def api_authenticate!
    @api = true
    bearer = request.env["HTTP_AUTHORIZATION"]

    if bearer 
        encoded_token = bearer.slice(7..-1)
        begin
            decoded_token = JWT.decode encoded_token, SECRET_KEY, true, {algorithm: 'HS256'} 
            user_id = decoded_token[0]["user_id"]
            @api_user = User.get(user_id)
        rescue JWT::DecodeError
            halt 401, 'A valid token must be passed'
        rescue JWT::ExpiredSignature
            halt 401, 'The token has expired'
        rescue JWT::InvalidIssuerError
            halt 401, 'The token does not have a valid issuer'
        rescue JWT::InvalidIatError
            halt 401, 'The token does not have a valid "issued at" time.'
        end
    else
        halt 401, 'A valid token must be passed.'
    end
end



def active_salon
    if @api
        return @api_user
    else
        if(session[:user_id])
            @u ||= User.first(id: session[:user_id])
            return @u 
        else
            nil
        end
    end
end