require Rails.root.join('app/lib/employee_seed_generator')

puts 'Starting employee seed...'

start_time = Time.current

Employee.delete_all

generator = EmployeeSeedGenerator.new

batch_size = 1000
total_records = 10_000

employees = []

total_records.times do |index|
  employees << generator.generate

  if employees.size >= batch_size
    Employee.insert_all(employees)

    puts "Inserted #{index + 1} employees"

    employees = []
  end
end

Employee.insert_all(employees) if employees.any?

duration = Time.current - start_time

puts "Done!"
puts "Total Employees: #{Employee.count}"
puts "Completed in #{duration.round(2)} seconds"
