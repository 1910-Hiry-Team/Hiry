require 'rainbow/refinement'
using Rainbow

puts 'Version 0.1.0'.green # For Debug purposes to be sure you're in the right file

puts ''
puts 'Do you want to skip the seeding and only reindex the database for elasticsearch? ('.blue + 'y'.green + '/'.blue + 'n'.red + ')'.blue
print '> '
answer = gets.chomp
unless answer == 'y'
  puts ''
  puts 'What weight of seeding do you want?'.blue
  puts '1. '.red + 'Light'
  puts '2. '.red + 'Medium'
  puts '3. '.red + 'Heavy' + ' (This will take a while)'.yellow
  print '> '

  case gets.chomp
  when /1\.?|l|light/i
    puts 'Light seeding Selected'.green
    NUMBER_OF_USERS = rand(10..20)
    NUMBER_OF_JOBS = rand(10..20)
  when /2\.?|m|medium/i
    puts 'Medium seeding Selected'.green
    NUMBER_OF_USERS = rand(50..100)
    NUMBER_OF_JOBS = rand(50..100)
  when /3\.?|h|heavy/i
    puts 'Heavy seeding Selected'.green
    puts 'This can take 10 minutes. Do you really want to proceed? ('.yellow + 'y'.green + '/'.yellow + 'n'.red + ')'.yellow
      print '> '
      answer = gets.chomp
      if answer == 'y'
        NUMBER_OF_USERS = rand(1000..2000)
        NUMBER_OF_JOBS = rand(1000..2000)
      else
        puts 'Exiting...'.red
        exit
      end
  else
    puts 'Invalid choice. Exiting...'.red
    exit
  end

  RANGE_OF_STUDIES = 3
  RANGE_OF_EXPERIENCES = 3
  RANGE_OF_APPLICATIONS = 5

  puts ''
  puts 'Do you want to generate real cities? ('.blue + 'y'.green + '/'.blue + 'n'.red + ')'.blue
  print '> '
  answer = gets.chomp
  if answer == 'y'
    puts 'Real cities selected'.green
    USE_REAL_CITIES = true
  else
    puts 'Fake cities selected'.red
    USE_REAL_CITIES = false
  end

  REAL_CITIES = [
                "Paris, France",
                "New York, NY, United States",
                "Brussels, Belgium",
                "London, UK",
                "Rome, Italy"
              ]

  puts ''
  puts 'Do you want to clear the database? ('.blue + 'y'.green + '/'.blue + 'n'.red + ')'.blue
  print '> '
  answer = gets.chomp
  if answer == 'y'
    puts "Clearing database...".yellow
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
  puts ''
  puts "Creating users...".cyan
  jobseeker_profiles_to_create = []
  companies_to_create = []
  NUMBER_OF_USERS.times do
    location = USE_REAL_CITIES ? REAL_CITIES.sample : "#{Faker::Address.city}, #{Faker::Address.country}"
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
        location: location
      }
    else
      companies_to_create << {
        user_id: user.id,
        name: Faker::Company.name,
        location: location,
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

  puts "Users created!".green

  # Create Jobs
  puts ''
  puts "Creating jobs...".cyan
  jobs_to_create = []
  NUMBER_OF_JOBS.times do
    location = USE_REAL_CITIES ? REAL_CITIES.sample : "#{Faker::Address.city}, #{Faker::Address.country}"
    geo = Geocoder.search(location).first
    lat, lon = geo&.latitude, geo&.longitude
    @languages = ["English", "French", "Spanish", "German", "Italian", "Chinese", "Japanese", "Russian", "Arabic", "Portuguese", "Dutch", "Korean", "Turkish", "Polish", "Swedish", "Danish", "Norwegian", "Finnish", "Greek", "Czech", "Hungarian", "Romanian", "Bulgarian", "Croatian", "Slovak", "Slovenian", "Lithuanian", "Latvian", "Estonian"]

    jobs_to_create << {
      job_title: Faker::Job.title,
      location: location,
      latitude: lat,
      longitude: lon,
      missions: Faker::Lorem.sentence(word_count: 10),
      contract: ["Full-time", "Part-time", "Contract", "Internship"].sample,
      language: @languages.sample,
      experience: ["Entry", "Intermediate", "Senior"].sample,
      salary: rand(30000..60000), # Adjust to fit your salary format
      company_id: companies.sample.id
    }

  end

  Job.import(jobs_to_create)

  jobs = Job.all

  puts "Jobs created!".green

  # Create Studies
  puts ''
  puts "Creating studies...".cyan
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

  puts 'Studies created!'.green

  # Create Experiences
  puts ''
  puts "Creating experiences...".cyan
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

  puts "Experiences created!".green

  # Create Applications
  puts ''
  puts "Creating applications...".cyan
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

  puts "Applications created!".green

  puts ''
  puts "Seeding completed!".green
  puts "Users created: " + "#{User.count}".red
  puts "Companies created: " + "#{Company.count}".red
  puts "Jobs created: " + "#{Job.count}".red
  puts "Studies created: " + "#{Study.count}".red
  puts "Experiences created: " + "#{Experience.count}".red
  puts "Applications created: " + "#{Application.count}".red
  puts "Time taken: " + "#{(Time.now - start_time).round(2)} seconds".red
end

# Reindex models
puts ''
puts "Reindexing models...".cyan
Job.reindex
puts "Reindexing completed!".green
puts ''
