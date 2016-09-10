class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def generate_access_token
    payload = { user_id: id }
    TokenManager::AuthToken.encode(payload)
  end

  def donator?
    false
  end

  def fridge?
    false
  end

  def volunteer?
    false
  end

  private

  def password_required?
    super && !fb_id.present?
  end
end
