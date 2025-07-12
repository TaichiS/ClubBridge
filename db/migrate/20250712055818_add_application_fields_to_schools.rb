class AddApplicationFieldsToSchools < ActiveRecord::Migration[8.0]
  def change
    add_column :schools, :school_type, :string
    add_column :schools, :address, :text
    add_column :schools, :website, :string
    add_column :schools, :description, :text
    add_column :schools, :contact_name, :string
    add_column :schools, :contact_title, :string
    add_column :schools, :contact_email, :string
    add_column :schools, :contact_phone, :string
    add_column :schools, :student_count, :string
    add_column :schools, :club_count, :string
    add_column :schools, :expected_start_date, :date
    add_column :schools, :notes, :text
    add_column :schools, :applicant_name, :string
    add_column :schools, :applicant_email, :string
    add_column :schools, :rejection_reason, :text
  end
end
