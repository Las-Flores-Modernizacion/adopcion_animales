class AddPhoneNumberToAccounts < ActiveRecord::Migration[8.0]
  def change
    add_column :accounts, :phone_number, :string
  end
end
