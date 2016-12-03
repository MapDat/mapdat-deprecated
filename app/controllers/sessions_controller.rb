class SessionsController < ApplicationController
  def new
  end

  def create
    logger.info params["email"]
    logger.info params["encrypted_password"]

    user = User.authenticate(params["email"], params["encrypted_password"])
    logger.info user
    if user
      session[:email] = params[:email]
      redirect_to '/'
    else
      redirect_to '/login'
    end
  end

  def destroy
    session[:email] = nil
    redirect_to '/'
  end
end
