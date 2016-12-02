class AuthController < ApplicationController
  require 'auth_token.rb'
  skip_before_action :verify_authenticity_token
  def authenticate
    # You'll need to implement the below method. It should return the
    # user instance if the username and password are valid.
    # Otherwise return nil.
    user = @connection.exec_query("SELECT * FROM users
                                   WHERE email = '#{params[:email]}' AND
                                   encrypted_password = '#{params[:password]}'")
    if user
      render json: authentication_payload(user.first)
    else
      render json: { errors: ['Invalid username or password'] }, status: :unauthorized
    end
  end

  private

  def authentication_payload(user)
    return nil unless user["email"] && user["encrypted_password"]
    {
      auth_token: AuthToken.encode({ auth_token: user["email"] }),
      user: { email: user["email"], first_name: user["first_name"], last_name: user["last_name"] } # return whatever user info you need
    }
  end
end
