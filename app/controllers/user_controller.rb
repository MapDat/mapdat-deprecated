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

  def show

  end

  def update
    authorize
    @connection = ActiveRecord::Base.connection
    if user_params[:prof_pic]
      uploaded_io = user_params[:prof_pic]
      extn = File.extname  uploaded_io.original_filename
      file_name = user_params[:first_name] + user_params[:last_name] + extn
      File.open(Rails.root.join('public', 'uploads', file_name), 'wb') do |file|
        file.write(uploaded_io.read)
      end
    end

    if user_params[:password]
      @connection.execute("UPDATE users SET img_path = '#{file_name}' WHERE email = '#{session[:email]}'")
    elsif user_params[:password] && user_params[:img_path]
      @connection.execute("UPDATE users SET img_path = '#{file_name}', password = '#{user_params[:encrypted_password]}WHERE email = '#{session[:email]}'")
    end

    redirect_to '/'
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :encrypted_password, :prof_pic)
  end
end
