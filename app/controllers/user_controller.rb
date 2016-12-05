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

    if user_params[:encrypted_password] == ""
      @connection.execute("UPDATE users SET img_path = '#{file_name}' WHERE email = '#{session[:email]}'")
    elsif user_params[:prof_pic].nil?
      @connection.execute("UPDATE users SET encrypted_password = '#{user_params[:encrypted_password]}' WHERE email = '#{session[:email]}'")
    else
      @connection.execute("UPDATE users SET img_path = '#{file_name}', encrypted_password = '#{user_params[:encrypted_password]}' WHERE email = '#{session[:email]}'")
    end

    @connection.execute("COMMIT")

    redirect_to '/'
  end

  def user_info
    user_info = current_user
    user_info.delete("encrypted_password")
    render json: JSON.pretty_generate(user_info)
  end



  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :encrypted_password, :prof_pic)
  end
end
