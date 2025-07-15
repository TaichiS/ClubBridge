class AddFieldsToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :announcement, :text
    add_column :schools, :top_announcement, :text
    add_column :schools, :club_selection_start_time, :datetime
    add_column :schools, :club_selection_end_time, :datetime
    add_column :schools, :result_announcement_start_time, :datetime
    add_column :schools, :result_announcement_end_time, :datetime
    add_column :schools, :semester_schedule, :text
  end
end
