class CreateRealtors < ActiveRecord::Migration[7.0]
  def change
    create_table :realtors do |t|
      t.string :name
      t.string :address
      t.string :email
      t.string :phone_number
      t.string :company

      t.timestamps
    end
  end
end
