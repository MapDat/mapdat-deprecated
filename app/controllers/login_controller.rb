class LoginController < ApplicationController

  def new
    render component: 'LoginForm', tag: 'span', class: 'login'

  end

end
