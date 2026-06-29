class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :provider
      t.string :uid
      t.string :oauth_token
      t.string :oauth_expires_at

      t.timestamps
    end
    add_index :accounts, :email_address, unique: true
  end
end
