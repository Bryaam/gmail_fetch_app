require 'rails_helper'

RSpec.describe User, type: :model do
  it 'User has a valid factory bot' do
    expect(FactoryBot.build(:user).save).to be true
  end

  it 'has a valid health iq domain on email' do
    user = FactoryBot.create(:user)
    user_email_domain = user.email.split('@').last
    expect(user_email_domain).to eq(ENV['HEALTH_IQ_DOMAIN'])
  end

  it 'is invalid without a unique email' do
    user = FactoryBot.create(:user)
    expect(FactoryBot.build(:user, email: user.email).save).to be false
  end

  it 'has an uid' do
    user = FactoryBot.create(:user)
    expect(user.uid).not_to be nil
  end

  it 'is created from oauth' do
    expire_time = DateTime.now
    auth = {
      provider: 'google',
      uid: '12345678910',
      info: {
        email: 'john_doe@testmail.com'
      },
      credentials: {
        token: 'abcdefg12345',
        refresh_token: '12345abcdefg',
        expires_at: expire_time,
      }
    }
    user = User.from_omniauth(auth)
    expect(user.email).to eq('john_doe@testmail.com')
    expect(user.uid).to eq('12345678910')
    expect(user.credential.access_token).to eq('abcdefg12345')
    expect(user.credential.refresh_token).to eq('12345abcdefg')
    expect(user.credential.expires_at.to_i).to eq(expire_time.to_i)
  end
end
