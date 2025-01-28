# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# db/seeds.rb

# Clear existing data to avoid duplication
Application.destroy_all
Job.destroy_all
Company.destroy_all
Experience.destroy_all
Study.destroy_all
User.destroy_all

# Create Users
puts "Creating users..."
10.times do
  User.create!(
  first_name: Faker::Name.first_name,
  last_name: Faker::Name.last_name,
  email: Faker::Internet.unique.email,
  password: "password123", # Provide a default password
  password_confirmation: "password123", # Confirm the password
  phone_number: Faker::PhoneNumber.phone_number,
  date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
  skills: Faker::Job.key_skill,
  hobbies: Faker::Hobby.activity,
  city: Faker::Address.city,
  country: Faker::Address.country,
  role: [0, 1].sample
)
end
users = User.all

# Create Companies
puts "Creating companies..."
5.times do
  Company.create!(
    name: Faker::Company.name,
    email: Faker::Internet.email,
    location: Faker::Address.city,
    description: Faker::Company.catch_phrase,
    industry: Faker::Company.industry,
    employee_number: rand(10..500),
    user: users.sample
  )
end
companies = Company.all

# Create Jobs
puts "Creating jobs..."
20.times do
  Job.create!(
    job_title: Faker::Job.title,
    location: Faker::Address.city,
    missions: Faker::Lorem.sentence(word_count: 10),
    contract: ["Full-time", "Part-time", "Contract", "Internship"].sample,
    language: Faker::ProgrammingLanguage.name,
    experience: ["Entry", "Mid", "Senior"].sample,
    salary: (30000..60000), # Adjust to fit your salary format
    company: companies.sample
  )
end
jobs = Job.all

# Create Studies
puts "Creating studies..."
users.each do |user|
  rand(1..3).times do
    Study.create!(
      school: Faker::University.name,
      level: ["Bachelor's", "Master's", "PhD"].sample,
      diploma: Faker::Educator.course_name,
      start_date: Faker::Date.backward(days: 3650),
      end_date: Faker::Date.backward(days: 365),
      user: user
    )
  end
end

# Create Experiences
puts "Creating experiences..."
users.each do |user|
  rand(1..3).times do
    Experience.create!(
      company: Faker::Company.name,
      job_title: Faker::Job.title,
      contrat: ["Full-time", "Part-time", "Contract"].sample,
      missions: Faker::Lorem.sentence(word_count: 10),
      description: Faker::Lorem.paragraph,
      start_date: Faker::Date.backward(days: 2000),
      end_date: Faker::Date.backward(days: 365),
      user: user
    )
  end
end

# Create Applications
puts "Creating applications..."
users.each do |user|
  rand(1..5).times do
    Application.create!(
      stage: ["Applied", "Interviewing", "Hired", "Rejected"].sample,
      match: [true, false].sample,
      user: user,
      job: jobs.sample,
    )
  end
end

puts "Seeding completed!"
