class CreateSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :surveys do |t|
      t.string :touchpoint
      t.integer :respondent_id
      t.integer :object_id
      t.string :respondent_class
      t.string :object_class
      t.integer :score

      t.timestamps
    end
  end
end
