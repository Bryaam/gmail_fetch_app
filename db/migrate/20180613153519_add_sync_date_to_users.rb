class AddSyncDateToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_sync, :datetime
  end
end
