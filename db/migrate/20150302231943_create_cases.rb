class CreateCases < ActiveRecord::Migration
  def change
    create_table :cases do |t|
      t.string :name
      t.date :date_of_birth
      t.string :email
      t.string :home_phone_number
      t.string :home_address
      t.string :home_zip_code
      t.string :home_city
      t.string :home_state
      t.string :primary_language
      t.string :sex
      t.json :additional_household_members
      t.boolean :contact_by_email
      t.boolean :contact_by_text_message
      t.boolean :contact_by_phone_call

      t.timestamps null: false
    end
  end
end
