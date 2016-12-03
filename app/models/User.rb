class User
  include ActiveModel::Model
  attr_accesor :email, :first_name, :last_name :encrypted_password,
               :reset_password_token, :last_sign_in_at, :current_sign_in_at,
               :last_sign_in_ip, :current_sign_in_ip

  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
end
