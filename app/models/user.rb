class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  def self.from_omniauth(auth)
      user = where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email ||= auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.photo_url = auth.extra.raw_info.photo_100
      end
      user.token = auth.credentials.token
      user
  end

  def email_required?
    false
  end
end
