require 'rails_helper'

RSpec.describe Credential, type: :model do
  it 'Credential has a valid factory bot' do
    user = FactoryBot.create(:user)
    expect(FactoryBot.build(:credential, user_id: user.id).save).to be true
  end
end
