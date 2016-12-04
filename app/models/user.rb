class User
  include ActiveModel::Model

  validates :email, presence: true
  validates :password, presence: true

  attr_accessor  :email, :first_name, :last_name, :encrypted_password,
                 :reset_password_token, :last_sign_in_at, :current_sign_in_at,
                 :last_sign_in_ip, :current_sign_in_ip

  def save
    @connection = ActiveRecord::Base.connection
    begin
      @connection.execute("INSERT INTO users VALUES(
                          '#{@email}', '#{@first_name}', '#{@last_name}', '#{@encrypted_password}', NULL)")
      return true
    rescue => error
      return false
    end
  end

  def self.find_by_email email
    @connection = ActiveRecord::Base.connection
    result = @connection.exec_query("SELECT * FROM users
                                     WHERE email = '#{email}'")

    result.first
  end

  def self.authenticate email, password
    @connection = ActiveRecord::Base.connection
    result = @connection.exec_query("SELECT * FROM users
                                     WHERE email = '#{email}'
                                     AND encrypted_password = '#{password}'")
    result.first ? true : false
  end
end
