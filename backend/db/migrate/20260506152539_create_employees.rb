class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :full_name, null: false
      t.string :job_title, null: false
      t.string :country, null: false
      t.integer :salary, null: false
      t.string :currency, null: false, default: 'USD'
      t.string :department
      t.timestamps
    end

    add_check_constraint :employees, 'salary > 0', name: 'salary_positive'

    add_index :employees, :country
    add_index :employees, :job_title
    add_index :employees, [:country, :job_title]
  end
end
