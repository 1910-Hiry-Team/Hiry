require 'open-uri'
require 'rainbow/refinement'
using Rainbow

puts 'Seeding v0.2.0'.green # For Debug purposes to be sure you're in the right file

# -------------------
# Variables
# -------------------
puts ''
puts 'Do you want to skip the seeding and only reindex the database for elasticsearch? ('.blue + 'y'.green + '/'.blue + 'n'.red + ')'.blue
print '> '
answer = gets.chomp
unless answer == 'y'
  puts ''
  puts 'What weight of seeding do you want?'.blue
  puts '1. '.red + 'Light' + ' (30s)'.green
  puts '2. '.red + 'Medium' + ' (200s)'.yellow
  puts '3. '.red + 'Heavy' + ' (1000s)'.red
  print '> '

  case gets.chomp
  when /1\.?|l|light/i
    puts 'Light seeding Selected'.green
    NUMBER_OF_USERS = rand(10..20)
    NUMBER_OF_JOBS = rand(5..10)
  when /2\.?|m|medium/i
    puts 'Medium seeding Selected'.green
    NUMBER_OF_USERS = rand(50..100)
    NUMBER_OF_JOBS = rand(25..50)
  when /3\.?|h|heavy/i
    puts 'Heavy seeding Selected'.green
    puts 'This can take 10 minutes. Do you really want to proceed? ('.yellow + 'y'.green + '/'.yellow + 'n'.red + ')'.yellow
      print '> '
      answer = gets.chomp
      if answer == 'y'
        NUMBER_OF_USERS = rand(1000..2000)
        NUMBER_OF_JOBS = rand(400..600)
      else
        puts 'Exiting...'.red
        exit
      end
  else
    puts 'Invalid choice. Exiting...'.red
    exit
  end

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

  puts ''
  puts 'Do you want to clear the database? ('.blue + 'y'.green + '/'.blue + 'n'.red + ')'.blue
  print '> '
  answer = gets.chomp
  if answer == 'y'
    puts 'Selected to clear the database'.yellow
    DATABASE_CLEAR = true
  else
    puts 'Selected to keep the database'.green
    DATABASE_CLEAR = false
  end

  # -------------------
  # Constants
  # -------------------
  t_constants = Time.now
  RANGE_OF_STUDIES = 3
  RANGE_OF_EXPERIENCES = 3
  RANGE_OF_APPLICATIONS = 5

  REAL_CITIES = [
                "Paris, France",
                "New York, NY, United States",
                "Brussels, Belgium",
                "London, UK",
                "Rome, Italy"
              ]
  t_stop_constants = Time.now

  # -------------------
  puts ''
  puts 'Fetching logos from Cloudinary...'.cyan
  t_logos = Time.now
  LOGOS = []
  begin
    next_cursor = nil
    loop do
      # Fetch all resources from the "logos" folder
      response = Cloudinary::Api.resources(type: 'upload',
                                            prefix: 'logos-company',
                                            max_results: 100,
                                            next_cursor: next_cursor)

      response['resources'].each do |resource|
        public_id = resource['public_id']
      # Check if the resource exists (if it's deleted, this will raise an error)
        begin
          Cloudinary::Api.resource(public_id) # This will succeed only if the resource exists
          LOGOS << public_id
        rescue Cloudinary::Api::NotFound
          puts "Skipping deleted logo: #{public_id}".red
        end
      end

      next_cursor = response['next_cursor']
      break unless next_cursor
    end
    puts "#{LOGOS.size} valid logos fetched from Cloudinary!".green
  rescue Cloudinary::Api::Error => e
    puts "Error fetching logos from Cloudinary: #{e.message}".red
  end
  t_stop_logos = Time.now

  # -------------------
  puts ''
  puts 'Fetching profile pictures from Cloudinary...'.cyan
  t_profile_pics = Time.now
  PROFILE_PICS = []
  begin
    next_cursor = nil
    loop do
      # Fetch all resources from the "logos" folder
      response = Cloudinary::Api.resources(type: 'upload',
                                            prefix: 'profile-pictures',
                                            max_results: 100,
                                            next_cursor: next_cursor)

      response['resources'].each do |resource|
        public_id = resource['public_id']
      # Check if the resource exists (if it's deleted, this will raise an error)
        begin
          Cloudinary::Api.resource(public_id) # This will succeed only if the resource exists
          PROFILE_PICS << public_id
        rescue Cloudinary::Api::NotFound
          puts "Skipping deleted profile picture: #{public_id}".red
        end
      end

      next_cursor = response['next_cursor']
      break unless next_cursor
    end
    puts "#{PROFILE_PICS.size} valid profile pictures fetched from Cloudinary!".green
  rescue Cloudinary::Api::Error => e
    puts "Error fetching profile pictures from Cloudinary: #{e.message}".red
  end
  t_stop_profile_pics = Time.now

  # -------------------
  # Clear the database
  # -------------------
  if DATABASE_CLEAR
    puts "Clearing database...".yellow
    t_clear_db = Time.now
    Application.in_batches(of: 1000).destroy_all
    Favorite.in_batches(of: 1000).destroy_all
    Job.in_batches(of: 1000).destroy_all
    Company.in_batches(of: 1000).destroy_all
    Experience.in_batches(of: 1000).destroy_all
    Study.in_batches(of: 1000).destroy_all
    User.in_batches(of: 1000).destroy_all
    puts "Database cleared!".green
    t_stop_clear_db = Time.now
  end

  # -------------------
  # Seed the database
  # -------------------
  start_time = Time.now

  # -------------------
  # Create Users
  # -------------------
  puts ''
  puts "Creating users...".cyan
  t_create_users = Time.now
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

  # -------------------
  # Create test users
  # -------------------
  if DATABASE_CLEAR # Only create test users if the database was cleared
    test_seeker = User.create!(
      email: 'test@seeker.com',
      password: '123456',
      password_confirmation: '123456',
      role: :jobseeker
    )

    test_company = User.create!(
      email: 'test@company.com',
      password: '123456',
      password_confirmation: '123456',
      role: :company
    )

    JobseekerProfile.create!(
      user_id: test_seeker.id,
      first_name: 'Test',
      last_name: 'Seeker',
      phone_number: '1234567890',
      date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
      skills: Faker::Job.key_skill,
      hobbies: Faker::Hobby.activity,
      location: 'Paris, France'
    )

    Company.create!(
      user_id: test_company.id,
      name: 'Test Company',
      location: 'Paris, France',
      description: 'We are a test company',
      industry: 'Test Industry',
      employee_number: 10
    )
  end

  JobseekerProfile.import(jobseeker_profiles_to_create)
  Company.import(companies_to_create)

  users = User.all
  companies = Company.all
  jobseeker_profiles = JobseekerProfile.all

  puts "Users created!".green
  t_stop_create_users = Time.now

  # ---------------------------
  # Assign logos to companies
  # ---------------------------
  puts ''
  puts "Assigning logos to companies...".cyan
  t_assign_logos = Time.now
  companies.each do |company|
    unless company.logo.attached?
      random_logo = LOGOS.sample # Get a random logo public_id
      logo_url = Cloudinary::Utils.cloudinary_url(random_logo) # Generate the logo URL
      company.logo.attach(io: URI.open(logo_url), filename: "logo_#{company.name}_#{Faker::Crypto.md5}.jpg")
    end
  end
  puts "Logos assigned to companies!".green
  t_stop_assign_logos = Time.now

  # ---------------------------------------
  # Assign profile pictures to jobseekers
  # ---------------------------------------
  puts ''
  puts "Assigning profile pictures to jobseekers...".cyan
  t_assign_profile_pics = Time.now
  jobseeker_profiles.each do |profile|
    unless profile.photo.attached?
      random_profile_pic = PROFILE_PICS.sample # Get a random profile picture public_id
      profile_pic_url = Cloudinary::Utils.cloudinary_url(random_profile_pic) # Generate the profile picture URL
      profile.photo.attach(io: URI.open(profile_pic_url), filename: "profile_pic_#{profile.user.email}_#{Faker::Crypto.md5}.jpg")
    end
  end
  puts "Profile pictures assigned to jobseekers".green
  t_stop_assign_profile_pics = Time.now

  # -------------------
  # Create Jobs
  # -------------------
  puts ''
  puts "Creating jobs...".cyan
  t_create_jobs = Time.now
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
  t_stop_create_jobs = Time.now

  # -------------------
  # Create Studies
  # -------------------
  puts ''
  puts "Creating studies...".cyan
  t_create_studies = Time.now
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
  t_stop_create_studies = Time.now

  # -------------------
  # Create Experiences
  # -------------------
  puts ''
  puts "Creating experiences...".cyan
  t_create_experiences = Time.now
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
  t_stop_create_experiences = Time.now

  # -------------------
  # Create Applications
  # -------------------
  puts ''
  puts "Creating applications...".cyan
  t_create_applications = Time.now
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
  t_stop_create_applications = Time.now

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

# -------------------
# Reindex models
# -------------------
puts ''
puts "Reindexing models...".cyan
t_reindex = Time.now
Job.reindex
puts "Reindexing completed!".green
t_stop_reindex = Time.now

puts ''
puts "Time taken for each step:".green
puts "Setting up constants: ".white + "#{(t_stop_constants - t_constants).round(2)} seconds".red
puts "Fetching logos: ".white + "#{(t_stop_logos - t_logos).round(2)} seconds".red
puts "Fetching profile pictures: ".white + "#{(t_stop_profile_pics - t_profile_pics).round(2)} seconds".red
puts "Clearing database: ".white + "#{(t_stop_clear_db - t_clear_db).round(2)} seconds".red if DATABASE_CLEAR
puts "Creating users: ".white + "#{(t_stop_create_users - t_create_users).round(2)} seconds".red
puts "Assigning logos: ".white + "#{(t_stop_assign_logos - t_assign_logos).round(2)} seconds".red
puts "Assigning profile pictures: ".white + "#{(t_stop_assign_profile_pics - t_assign_profile_pics).round(2)} seconds".red
puts "Creating jobs: ".white + "#{(t_stop_create_jobs - t_create_jobs).round(2)} seconds".red
puts "Creating studies: ".white + "#{(t_stop_create_studies - t_create_studies).round(2)} seconds".red
puts "Creating experiences: ".white + "#{(t_stop_create_experiences - t_create_experiences).round(2)} seconds".red
puts "Creating applications: ".white + "#{(t_stop_create_applications - t_create_applications).round(2)} seconds".red
puts "Reindexing: ".white + "#{(t_stop_reindex - t_reindex).round(2)} seconds".red
