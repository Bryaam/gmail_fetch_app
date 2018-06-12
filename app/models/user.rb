class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2]

  has_one :credential, dependent: :destroy

  def self.from_omniauth(access_token)
    data = access_token.info
    credentials = access_token.credentials
    user = User.where(email: data['email']).first

    unless user
      user = User.create(
        email: data['email'],
        uid: access_token.uid,
        password: Devise.friendly_token[0,20]
      )
      user.create_credential(
        access_token: credentials['token'],
        expires_at: Time.at(credentials['expires_at']).to_datetime,
        refresh_token: credentials['refresh_token']
      )
    end
    user
  end
end
