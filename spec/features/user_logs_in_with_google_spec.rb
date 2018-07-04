require 'rails_helper'

RSpec.feature 'user logs in' do
  before do
    request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:google]
  end
  scenario 'using google oauth2' do
    #Capybara.current_driver = :selenium_chrome
    #stub_omniauth

    OmniAuth.config.test_mode = true
    # then, provide a set of fake oauth data that
    # omniauth will use when a user tries to authenticate:
    # OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
    #   provider: 'google',
    #   uid: '12345678910',
    #   info: {
    #     email: 'john_doe@testmail.com'
    #   },
    #   credentials: {
    #     token: 'abcdefg12345',
    #     refresh_token: '12345abcdefg',
    #     expires_at: DateTime.now
    #   }
    # })

    omniauth_hash = {
      provider: 'google',
      uid: '12345678910',
      info: {
        email: 'john_doe@testmail.com'
      },
      credentials: {
        token: 'abcdefg12345',
        refresh_token: '12345abcdefg',
        expires_at: DateTime.now,
      }
    }

    OmniAuth.config.add_mock(:google, omniauth_hash)

    visit new_user_session_path
    expect(page).to have_link('Sign in with GoogleOauth2')
    click_link 'Sign in with GoogleOauth2'
    expect(page).to have_content('john_doe@testmail.com')
    #Capybara.use_default_driver
  end

  def stub_omniauth
    # first, set OmniAuth to run in test mode
    OmniAuth.config.test_mode = true
    # then, provide a set of fake oauth data that
    # omniauth will use when a user tries to authenticate:
    OmniAuth.config.mock_auth[:google] = OmniAuth::AuthHash.new({
      provider: 'google',
      uid: '12345678910',
      info: {
        email: 'john_doe@testmail.com'
      },
      credentials: {
        token: 'abcdefg12345',
        refresh_token: '12345abcdefg',
        expires_at: DateTime.now
      }
    })
  end
end
