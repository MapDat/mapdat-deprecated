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
      file_name = (0...15).map { ('a'..'z').to_a[rand(26)] }.join
      extn = File.extname  uploaded_io.original_filename
      file_name = file_name + extn
      File.open(Rails.root.join('app', 'assets', 'images', file_name), 'wb') do |file|
        file.write(uploaded_io.read)
      end
    end


    case user_params
    when user_params[:encrypted_password] && user_params[:img_path].nil?
      @connection.execute("UPDATE users SET encrypted_password = '#{user_params[:encrypted_password]}' WHERE email = '#{session[:email]}'")
    when user_params[:encrypted_password] && user_params[:img_path]
      @connection.execute("UPDATE users SET img_path = '#{file_name}', encrypted_password = '#{user_params[:encrypted_password]}' WHERE email = '#{session[:email]}'")
    when user_params[:encrypted_password].nil? && user_params[:img_path]
      @connection.execute("UPDATE users SET img_path = '#{file_name}' WHERE email = '#{session[:email]}'")
    end

    redirect_to '/'
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :encrypted_password, :prof_pic)
  end
end
