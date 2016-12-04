module HomeHelper
  def show_prof_pic
    if @current_user
      path = @connection.exec_query("SELECT img_path FROM users
                                     WHERE email = '#{session[:email]}'")
    end
    "public/uploads/#{path}"
  end
end
