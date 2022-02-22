class CreateDeals < ActiveRecord::Migration[7.0]
  def change
    create_table :deals do |t|
      t.integer :property_id
      t.integer :realtor_id
      t.integer :seller_id

      t.timestamps
    end
  end
end
