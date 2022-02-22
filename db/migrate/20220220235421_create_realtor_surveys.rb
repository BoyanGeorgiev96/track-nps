class CreateRealtorSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :realtor_surveys do |t|
      t.integer :realtor_id
      t.integer :survey_id

      t.timestamps
    end
  end
end
