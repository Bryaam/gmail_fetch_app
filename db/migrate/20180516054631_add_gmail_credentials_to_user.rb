class AddGmailCredentialsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :uid, :string, null: false
  end
end
