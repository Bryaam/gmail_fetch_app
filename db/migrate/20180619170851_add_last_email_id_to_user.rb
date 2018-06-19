class AddLastEmailIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_email_id, :string
  end
end
