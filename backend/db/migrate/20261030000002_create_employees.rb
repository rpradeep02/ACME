class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string :employee_code, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :country_code, null: false
      t.string :department, null: false
      t.string :job_title, null: false
      t.string :status, null: false, default: "active"
      t.date :hire_date, null: false
      t.timestamps
    end
    add_index :employees, :employee_code, unique: true
    add_index :employees, :email, unique: true
    add_index :employees, :country_code
    add_index :employees, :department
    add_index :employees, :status
    add_index :employees, %i[country_code department status]
  end
end
