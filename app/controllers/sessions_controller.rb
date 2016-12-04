class SessionsController < ApplicationController
  def new
  end

  def create
    logger.info params["email"]
    logger.info params["encrypted_password"]

    # if you're reading this, hi!

    user = User.authenticate(params["email"], params["encrypted_password"])
    logger.info user
    if user
      session[:email] = params[:email]
      redirect_to '/'
    else
      flash[:error] = "Invalid username/password"
      redirect_to '/'
    end
  end

  def destroy
    session[:email] = nil
    redirect_to '/'
  end
end
