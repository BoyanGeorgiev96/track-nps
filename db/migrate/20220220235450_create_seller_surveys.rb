class CreateSellerSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :seller_surveys do |t|
      t.integer :seller_id
      t.integer :survey_id

      t.timestamps
    end
  end
end
