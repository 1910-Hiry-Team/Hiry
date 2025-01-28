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
  # First create the user
  user = User.create!(
    email: Faker::Internet.unique.email,
    password: "password123",
    password_confirmation: "password123",
    role: [:jobseeker, :company].sample
  )

  # Then create the associated profile
  if user.jobseeker?
    JobseekerProfile.create!(
      user: user,
      first_name: Faker::Name.first_name,
      last_name: Faker::Name.last_name,
      phone_number: Faker::PhoneNumber.phone_number,
      date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
      skills: Faker::Job.key_skill,
      hobbies: Faker::Hobby.activity,
      city: Faker::Address.city,
      country: Faker::Address.country
    )
  else
    Company.create!(
      user: user,
      name: Faker::Company.name,
      email: Faker::Internet.email,
      location: Faker::Address.city,
      description: Faker::Company.catch_phrase,
      industry: Faker::Company.industry,
      employee_number: rand(10..500)
    )
  end
end

users = User.all
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
User.where(role: 0).each do |user|
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
User.where(role: 0).each do |user|
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
User.where(role: 0).each do |user|
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
