class CreateSchoolSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :school_settings do |t|
      t.text :welcome_message
      t.datetime :enrollment_start_time
      t.datetime :enrollment_end_time
      t.datetime :result_publication_start_time
      t.datetime :result_publication_end_time
      t.references :school, null: false, foreign_key: true

      t.timestamps
    end
  end
end
