class CreateCredentials < ActiveRecord::Migration[5.2]
  def change
    create_table :credentials do |t|
      t.references :user, foreign_key: true
      t.string :access_token
      t.string :refresh_token
      t.string :expires_at

      t.timestamps
    end
  end
end
