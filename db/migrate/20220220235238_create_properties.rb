class CreateProperties < ActiveRecord::Migration[7.0]
  def change
    create_table :properties do |t|
      t.string :type
      t.string :address
      t.integer :seller_id

      t.timestamps
    end
  end
end
