puts 'What weight of seeding do you want?'
puts '1. Light'
puts '2. Medium'
puts '3. Heavy'
print '> '

case gets.chomp.to_i
when 1
  puts 'Light seeding Selected'
  NUMBER_OF_USERS = rand(10..20)
  NUMBER_OF_JOBS = rand(10..20)
when 2
  puts 'Medium seeding Selected'
  NUMBER_OF_USERS = rand(50..100)
  NUMBER_OF_JOBS = rand(50..100)
when 3
  puts 'Heavy seeding Selected'
  NUMBER_OF_USERS = rand(1000..2000)
  NUMBER_OF_JOBS = rand(1000..2000)
else
  puts 'Invalid choice. Exiting...'
end

RANGE_OF_STUDIES = 3
RANGE_OF_EXPERIENCES = 3
RANGE_OF_APPLICATIONS = 5

puts 'Do you want to generate real cities? (y/n)'
print '> '
answer = gets.chomp
if answer == 'y'
  USE_REAL_CITIES = true
else
  USE_REAL_CITIES = false
end

REAL_CITIES = [
              "Paris, France",
              "New York, NY, United States",
              "Brussels, Belgium",
              "London, UK",
              "Rome, Italy"
            ]

puts 'Do you want to clear the database? (y/n)'
print '> '
answer = gets.chomp
if answer == 'y'
  puts "Clearing database..."
  # Clear existing data to avoid duplication
  Application.destroy_all
  Job.destroy_all
  Company.destroy_all
  Experience.destroy_all
  Study.destroy_all
  User.destroy_all
end

start_time = Time.now

# Create Users
puts "Creating users..."
jobseeker_profiles_to_create = []
companies_to_create = []
NUMBER_OF_USERS.times do
  city = USE_REAL_CITIES ? REAL_CITIES.sample : Faker::Address.city
  # First create the user
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: "password123",
    password_confirmation: "password123",
    role: [:jobseeker, :company].sample
  )

  # Then create the associated profile
  if user.jobseeker?
    jobseeker_profiles_to_create << {
      user_id: user.id,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      phone_number: Faker::PhoneNumber.phone_number,
      date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
      skills: Faker::Job.key_skill,
      hobbies: Faker::Hobby.activity,
      city: city,
      country: Faker::Address.country
    }
  else
    companies_to_create << {
      user_id: user.id,
      name: Faker::Company.name,
      location: city,
      description: Faker::Company.catch_phrase,
      industry: Faker::Company.industry,
      employee_number: rand(10..500)
    }
  end
end

JobseekerProfile.import(jobseeker_profiles_to_create)
Company.import(companies_to_create)

users = User.all
companies = Company.all


# Create Jobs
puts "Creating jobs..."
jobs_to_create = []
NUMBER_OF_JOBS.times do
  city = USE_REAL_CITIES ? REAL_CITIES.sample : Faker::Address.city
  geo = Geocoder.search(city).first
  lat, lon = geo&.latitude, geo&.longitude

  jobs_to_create << {
    job_title: Faker::Job.title,
    location: city,
    latitude: lat,
    longitude: lon,
    missions: Faker::Lorem.sentence(word_count: 10),
    contract: ["Full-time", "Part-time", "Contract", "Internship"].sample,
    language: Faker::ProgrammingLanguage.name,
    experience: ["Entry", "Mid", "Senior"].sample,
    salary: rand(30000..60000), # Adjust to fit your salary format
    company_id: companies.sample.id
  }

end

Job.import(jobs_to_create)

jobs = Job.all

# Create Studies
puts "Creating studies..."
studies_to_create = []
User.where(role: 0).each do |user|
  rand(1.. RANGE_OF_STUDIES).times do
    studies_to_create << {
      school: Faker::University.name,
      level: ["Bachelor's", "Master's", "PhD"].sample,
      diploma: Faker::Educator.course_name,
      start_date: Faker::Date.backward(days: 3650),
      end_date: Faker::Date.backward(days: 365),
      user_id: user.id
    }
  end
end

Study.import(studies_to_create)

# Create Experiences
puts "Creating experiences..."
experiences_to_create = []
User.where(role: 0).each do |user|
  rand(1.. RANGE_OF_EXPERIENCES).times do
    experiences_to_create << {
      company: Faker::Company.name,
      job_title: Faker::Job.title,
      contrat: ["Full-time", "Part-time", "Contract"].sample,
      missions: Faker::Lorem.sentence(word_count: 10),
      description: Faker::Lorem.paragraph,
      start_date: Faker::Date.backward(days: 2000),
      end_date: Faker::Date.backward(days: 365),
      user_id: user.id
    }
  end
end

Experience.import(experiences_to_create)

# Create Applications
puts "Creating applications..."
applications_to_create = []
User.where(role: 0).each do |user|
  rand(1.. RANGE_OF_APPLICATIONS).times do
    applications_to_create << {
      stage: ["Applied", "Interviewing", "Hired", "Rejected"].sample,
      match: [true, false].sample,
      user_id: user.id,
      job_id: jobs.sample.id,
    }
  end
end

Application.import(applications_to_create)

puts "Seeding completed!"
puts "Users created: #{User.count}"
puts "Companies created: #{Company.count}"
puts "Jobs created: #{Job.count}"
puts "Studies created: #{Study.count}"
puts "Experiences created: #{Experience.count}"
puts "Applications created: #{Application.count}"
puts "Time taken: #{Time.now - start_time} seconds"

puts "Reindexing models..."
Job.reindex
puts "Reindexing completed!"
