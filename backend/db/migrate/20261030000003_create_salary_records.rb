class CreateSalaryRecords < ActiveRecord::Migration[7.1]
  def change
    create_table :salary_records do |t|
      t.references :employee, null: false, foreign_key: true
      t.decimal :annual_salary, precision: 14, scale: 2, null: false
      t.string :currency, limit: 3, null: false
      t.date :effective_from, null: false
      t.date :effective_to
      t.timestamps
    end
    add_index :salary_records, %i[employee_id effective_from], unique: true
    add_index :salary_records, %i[currency effective_from effective_to], name: "idx_salary_currency_dates"
    add_index :salary_records, %i[employee_id effective_from effective_to], name: "idx_salary_employee_effective_period"
    add_check_constraint :salary_records, "annual_salary > 0", name: "salary_records_positive_amount"
    add_check_constraint :salary_records, "length(currency) = 3", name: "salary_records_currency_length"
  end
end
