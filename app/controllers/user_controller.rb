class UserController < ApplicationController
  def new
  end

  def create
    user = User.new(user_params)
    if user.save
      session[:email] = user.email
      redirect_to '/'
    else
      redirect_to '/signup'
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :encrypted_password)
  end
end
