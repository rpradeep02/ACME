# Deterministic, repeatable assessment dataset. insert_all keeps 10k-row seeding practical.
password = ENV["SEED_ADMIN_PASSWORD"].presence || (Rails.env.production? ? nil : "ChangeMe123!")
raise "Set SEED_ADMIN_PASSWORD before seeding production" if password.blank?

User.find_or_create_by!(email: "hr.manager@acme.example") do |user|
  user.password = password
  user.role = "hr_manager"
end

first_names = %w[Ava Noah Mia Liam Emma Ethan Sofia Lucas Aria Oliver Zoe James Isla Mateo Ella]
last_names = %w[Sharma Patel Smith Brown Wilson Martin Garcia Clark Singh Miller Davis Taylor Khan White]
departments = ["Engineering", "Product", "People", "Finance", "Sales", "Marketing", "Operations", "Customer Success"]
countries = { "US" => "USD", "IN" => "INR", "GB" => "GBP", "DE" => "EUR", "CA" => "CAD", "SG" => "SGD", "AU" => "AUD", "AE" => "AED" }
titles = ["Software Engineer", "Senior Engineer", "Product Manager", "Analyst", "HR Partner", "Account Executive", "Designer", "Operations Lead"]
random = Random.new(20_261_030)
seed_date = Date.new(2026, 1, 1)
now = Time.current

employee_rows = []
salary_attributes = {}
1.upto(10_000) do |number|
  code = format("EMP%05d", number)
  country = countries.keys[(number - 1) % countries.length]
  first = first_names[random.rand(first_names.length)]
  last = last_names[random.rand(last_names.length)]
  employee_rows << {
    employee_code: code, first_name: first, last_name: last,
    email: "#{code.downcase}@acme.example", country_code: country,
    department: departments[(number - 1) % departments.length],
    job_title: titles[(number - 1) % titles.length],
    status: number % 47 == 0 ? "on_leave" : "active",
    hire_date: Date.new(2017, 1, 1) + random.rand(0..3_500),
    created_at: now, updated_at: now
  }

  base_salary = case country
                when "IN" then random.rand(700_000..3_200_000)
                when "US" then random.rand(65_000..190_000)
                when "GB" then random.rand(38_000..110_000)
                when "DE" then random.rand(42_000..120_000)
                when "CA" then random.rand(60_000..160_000)
                when "SG" then random.rand(55_000..160_000)
                when "AU" then random.rand(70_000..175_000)
                else random.rand(150_000..420_000)
                end
  salary_attributes[code] = { annual_salary: base_salary, currency: countries.fetch(country), effective_from: seed_date }
end

Employee.transaction do
  employee_rows.each_slice(1_000) do |batch|
    Employee.insert_all(batch, unique_by: :index_employees_on_employee_code)
  end

  ids_by_code = Employee.where(employee_code: employee_rows.map { |row| row[:employee_code] })
                        .pluck(:employee_code, :id).to_h
  salary_rows = salary_attributes.map do |code, values|
    values.merge(employee_id: ids_by_code.fetch(code), created_at: now, updated_at: now)
  end
  salary_rows.each_slice(1_000) do |batch|
    SalaryRecord.insert_all(batch, unique_by: :index_salary_records_on_employee_id_and_effective_from)
  end
end

puts "Seeded #{Employee.count} employees, #{SalaryRecord.count} salary records, and #{User.count} HR user(s)."
