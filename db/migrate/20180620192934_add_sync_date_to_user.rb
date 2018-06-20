class AddSyncDateToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_sync, :datetime
    add_column :users, :last_email_id, :string
  end
end
