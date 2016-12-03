class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.authenticate(params["email"], params["encrypted_password"])

    if user
      session[:email] = params[:email]
    else
      redirect_to '/login'
    end
  end

  def destroy
    session[:email] = nil
    redirect_to '/login'
  end

  private

  def session_params
    params.require(:user)
  end
end
