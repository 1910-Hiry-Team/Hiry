require 'open-uri'
require 'parallel'
require 'rainbow/refinement'
using Rainbow

puts 'Seeding v0.4.3'.green # For Debug purposes to be sure you're in the right file

# -------------------
# Initial setup
# -------------------
module SeedConfig
  RANGE_OF_STUDIES = 3
  RANGE_OF_EXPERIENCES = 3
  RANGE_OF_APPLICATIONS = 5

  SALARY_RANGE = 30000..60000

  THREADS_TO_USE = 4

  REAL_CITIES = [
    "Paris, France",
    "New York, NY, United States",
    "Brussels, Belgium",
    "London, UK",
    "Rome, Italy"
  ]

  REAL_LANGUAGES = [
    "English",
    "French",
    "Spanish",
    "German",
    "Italian",
    "Chinese",
    "Japanese",
    "Russian",
    "Arabic",
    "Portuguese",
    "Dutch",
    "Korean",
    "Turkish",
    "Polish",
    "Swedish",
    "Danish",
    "Norwegian",
    "Finnish",
    "Greek",
    "Czech",
    "Hungarian",
    "Romanian",
    "Bulgarian",
    "Croatian",
    "Slovak",
    "Slovenian",
    "Lithuanian",
    "Latvian",
    "Estonian"]
end

class DbHandler
  # -------------------
  # Clear the database
  # ----------------
  def self.clear_database(batch)
    Application.in_batches(of: batch).destroy_all
    Favorite.in_batches(of: batch).destroy_all
    Job.in_batches(of: batch).destroy_all
    Company.in_batches(of: batch).destroy_all
    Experience.in_batches(of: batch).destroy_all
    Study.in_batches(of: batch).destroy_all
    User.in_batches(of: batch).destroy_all
  end

  # -------------------
  # Import models
  # -------------------
  def self.model_importer(model, model_to_import)
    model.import(model_to_import)
  end
end

class SeederHandler
  # -------------------
  # Create test users
  # -------------------
  def self.create_test_users
    test_seeker = User.create!(email: 'test@seeker.com', password: '123456',
                              password_confirmation: '123456', role: :jobseeker)

    test_company = User.create!(email: 'test@company.com', password: '123456',
                                password_confirmation: '123456', role: :company)

    JobseekerProfile.create!(user_id: test_seeker.id, first_name: 'Test',
                            last_name: 'Seeker', phone_number: '1234567890',
                            date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
                            skills: Faker::Job.key_skill, hobbies: Faker::Hobby.activity,
                            location: 'Paris, France')

    Company.create!(user_id: test_company.id, name: 'Test Company',
                    location: 'Paris, France', description: 'We are a test company',
                    industry: 'Test Industry', employee_number: 10)
  end

  # -------------------
  # Create users
  # -------------------
  def self.create_users(number_of_users)
    users_to_create = []
    Parallel.each(1..number_of_users, in_threads: SeedConfig::THREADS_TO_USE) do
      users_to_create << User.new(
      email: Faker::Internet.unique.email,
      password: '123456',
      password_confirmation: '123456',
      role: [:jobseeker, :company].sample
      )
    end
    return users_to_create
  end

  def self.create_profiles_and_companies(users, use_real_cities)
    jobseeker_profiles_to_create = []
    companies_to_create = []
    Parallel.each(users, in_threads: SeedConfig::THREADS_TO_USE) do |user|
      location = use_real_cities ? SeedConfig::REAL_CITIES.sample : "#{Faker::Address.city}, #{Faker::Address.country}"

      if user[:role] == :jobseeker
        jobseeker_profiles_to_create << JobseekerProfile.new(
          user_id: user[:id],
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          phone_number: Faker::PhoneNumber.phone_number,
          date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
          skills: Faker::Job.key_skill, hobbies: Faker::Hobby.activity,
          location: location
        )
      else
        companies_to_create << Company.new(
          user_id: user[:id],
          name: Faker::Company.name,
          location: location,
          description: Faker::Company.catch_phrase,
          industry: Faker::Company.industry,
          employee_number: rand(10..500)
        )
      end
    end
    return jobseeker_profiles_to_create, companies_to_create
  end

  # ---------------------------
  # Create jobs
  # ---------------------------
  def self.create_jobs(number_of_jobs, use_real_cities, companies)
    jobs_to_create = []
    Parallel.each(1..number_of_jobs, in_threads: SeedConfig::THREADS_TO_USE) do
      location = use_real_cities ? SeedConfig::REAL_CITIES.sample : "#{Faker::Address.city}, #{Faker::Address.country}"
      geo = Geocoder.search(location).first
      lat, lon = geo&.latitude, geo&.longitude

      jobs_to_create << Job.new(
      job_title: Faker::Job.title,
      location: location,
      latitude: lat,
      longitude: lon,
      missions: Faker::Lorem.sentence(word_count: 10),
      contract: ["Full-time", "Part-time", "Contract", "Internship"].sample,
      language: SeedConfig::REAL_LANGUAGES.sample,
      experience: ["Entry", "Intermediate", "Senior"].sample,
      salary: rand(SeedConfig::SALARY_RANGE), # Adjust to fit your salary format
      company_id: companies.sample[:id]
      )
    end
    return jobs_to_create
  end

  # -------------------
  # Create studies
  # -------------------
  def self.create_studies(users)
    studies_to_create = []
    Parallel.each(users.select { |user| user[:role] == :jobseeker }, in_threads: SeedConfig::THREADS_TO_USE) do |user|
      rand(1.. SeedConfig::RANGE_OF_STUDIES).times do
        studies_to_create << Study.new(
          school: Faker::University.name,
          level: ["Bachelor's", "Master's", "PhD"].sample,
          diploma: Faker::Educator.course_name,
          start_date: Faker::Date.backward(days: 3650),
          end_date: Faker::Date.backward(days: 365),
          user_id: user[:id]
        )
      end
    end
    return studies_to_create
  end

  # -------------------
  # Create experiences
  # -------------------
  def self.create_experiences(users)
    experiences_to_create = []
    Parallel.each(users.select { |user| user[:role] == :jobseeker }, in_threads: SeedConfig::THREADS_TO_USE) do |user|
      rand(1.. SeedConfig::RANGE_OF_EXPERIENCES).times do
        experiences_to_create << Experience.new(
          company: Faker::Company.name,
          job_title: Faker::Job.title,
          contrat: ["Full-time", "Part-time", "Contract"].sample,
          missions: Faker::Lorem.sentence(word_count: 10),
          description: Faker::Lorem.paragraph,
          start_date: Faker::Date.backward(days: 2000),
          end_date: Faker::Date.backward(days: 365),
          user_id: user[:id]
        )
      end
    end
    return experiences_to_create
  end

  # -------------------
  # Create applications
  # -------------------
  def self.create_applications(users, jobs)
    applications_to_create = []
    Parallel.each(users.select { |user| user[:role] == :jobseeker }, in_threads: SeedConfig::THREADS_TO_USE) do |user|
      rand(1.. SeedConfig::RANGE_OF_APPLICATIONS).times do
        applications_to_create << Application.new(
          stage: ["Applied", "Interviewing", "Hired", "Rejected"].sample,
          match: [true, false].sample,
          user_id: user[:id],
          job_id: jobs.sample[:id]
        )
      end
    end
    return applications_to_create
  end
end

class ImageHandler
  # -------------------
  # Fetch Cloudinary images
  # -------------------
  def self.fetch_cloudinary_resources(prefix, name)
    resources = []
    next_cursor = nil
    loop do
      response = Cloudinary::Api.resources(type: 'upload',
                                            prefix: prefix,
                                            max_results: 100,
                                            next_cursor: next_cursor)
      Parallel.each(response['resources'], in_threads: SeedConfig::THREADS_TO_USE) do |resource|
        public_id = resource['public_id']
        begin
          Cloudinary::Api.resource(public_id)
          resources << public_id
        rescue Cloudinary::Api::NotFound
          puts "Skipping deleted #{name.pluralize}: #{public_id}".red
        end
      end
      next_cursor = response['next_cursor']
      break unless next_cursor
    end
    puts "#{resources.size} valid #{name.pluralize} fetched from Cloudinary!".green
    return resources
  rescue Cloudinary::Api::Error => e
    puts "Error fetching #{name.pluralize} from Cloudinary: #{e.message}".red
    []
  end

  # -------------------
  # Assign images to models
  # -------------------
  def self.assign_images(records, model)
    Parallel.each(records, in_threads: SeedConfig::THREADS_TO_USE) do |record|
      file_name = record.class == Company ? record.name : "#{record.first_name} #{record.last_name}"
      unless record.photo.attached?
        random_photo = model.sample # Get a random photo public_id
        photo_url = Cloudinary::Utils.cloudinary_url(random_photo) # Generate the photo URL
        record.photo.attach(io: URI.open(photo_url), filename: "#{file_name}.jpg")
      end
    end
  end
end

# -------------------
# Handles the terminal interface
# -------------------
class SeederView
  def self.seeding
    puts ''
    puts 'What weight of seeding do you want?'.blue
    puts '1. '.red + 'Light' + ' (15s)'.green
    puts '2. '.red + 'Medium' + ' (70s)'.yellow
    puts '3. '.red + 'Heavy' + ' (500s)'.red
    print '> '

    case gets.chomp
    when /1\.?|l|light/i
      puts 'Light seeding Selected'.green
      number_of_users = rand(10..20)
      number_of_jobs = rand(5..10)
    when /2\.?|m|medium/i
      puts 'Medium seeding Selected'.green
      number_of_users = rand(50..100)
      number_of_jobs = rand(25..50)
    when /3\.?|h|heavy/i
      puts 'Heavy seeding Selected'.green
      puts 'This can take 10 minutes. Do you really want to proceed? ('.yellow + 'y'.green + '/'.yellow + 'n'.red + ')'.yellow
      print '> '
      answer = gets.chomp
      if answer == 'y'
        number_of_users = rand(1000..2000)
        number_of_jobs = rand(400..600)
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
    use_real_cities = gets.chomp == 'y'
    puts 'Real cities selected'.green if use_real_cities

    puts ''
    puts 'Do you want to clear the database? ('.blue + 'y'.green + '/'.blue + 'n'.red + ')'.blue
    print '> '
    clear_database = gets.chomp == 'y'

    if clear_database
      puts ''
      puts "Clearing database...".yellow
      t_clear_db = Time.now
      DbHandler.clear_database(1000)
      SeederHandler.create_test_users
      puts "Database cleared!".green
      t_stop_clear_db = Time.now
    end

    puts ''
    puts 'Fetching logos from Cloudinary...'.cyan
    t_logos = Time.now
    logos = ImageHandler.fetch_cloudinary_resources('logos-company', 'logo')
    t_stop_logos = Time.now

    puts ''
    puts 'Fetching profile pictures from Cloudinary...'.cyan
    t_profile_pics = Time.now
    profile_pics = ImageHandler.fetch_cloudinary_resources('profile-pictures', 'profile picture')
    t_stop_profile_pics = Time.now

    puts ''
    puts "Creating users...".cyan
    t_create_users = Time.now
    users = SeederHandler.create_users(number_of_users)
    puts "Users created and imported!".green
    t_stop_create_users = Time.now

    puts ''
    puts "Creating profiles and companies...".cyan
    t_create_profiles = Time.now
    jobseeker_profiles, companies = SeederHandler.create_profiles_and_companies(users, use_real_cities)
    puts "Profiles and companies created!".green
    t_stop_create_profiles = Time.now

    puts ''
    puts "Creating jobs...".cyan
    t_create_jobs = Time.now
    jobs = SeederHandler.create_jobs(number_of_jobs, use_real_cities, companies)
    puts "Jobs created!".green
    t_stop_create_jobs = Time.now

    puts ''
    puts "Creating studies...".cyan
    t_create_studies = Time.now
    studies = SeederHandler.create_studies(users)
    puts 'Studies created!'.green
    t_stop_create_studies = Time.now

    puts ''
    puts "Creating experiences...".cyan
    t_create_experiences = Time.now
    experiences = SeederHandler.create_experiences(users)
    puts "Experiences created!".green
    t_stop_create_experiences = Time.now

    puts ''
    puts "Creating applications...".cyan
    t_create_applications = Time.now
    applications = SeederHandler.create_applications(users, jobs)
    puts "Applications created!".green
    t_stop_create_applications = Time.now

    puts ''
    puts 'Importing the models...'.cyan
    t_import_models = Time.now
    DbHandler.model_importer(User, users)
    DbHandler.model_importer(JobseekerProfile, jobseeker_profiles)
    DbHandler.model_importer(Company, companies)
    DbHandler.model_importer(Study, studies)
    DbHandler.model_importer(Experience, experiences)
    DbHandler.model_importer(Application, applications)
    puts 'Models imported!'.green
    t_stop_import_models = Time.now

    puts ''
    puts "Assigning logos to companies...".cyan
    t_assign_logos = Time.now
    ImageHandler.assign_images(Company.all, logos)
    puts "Logos assigned to companies!".green
    t_stop_assign_logos = Time.now

    puts ''
    puts "Assigning profile pictures to jobseekers...".cyan
    t_assign_profile_pics = Time.now
    ImageHandler.assign_images(JobseekerProfile.all, profile_pics)
    puts "Profile pictures assigned to jobseekers".green
    t_stop_assign_profile_pics = Time.now


    puts ''
    puts "Seeding completed!".green
    puts "Users created: " + "#{User.count}".red
    puts "Jobseeker profiles created: " + "#{JobseekerProfile.count}".red
    puts "Companies created: " + "#{Company.count}".red
    puts "Jobs created: " + "#{Job.count}".red
    puts "Studies created: " + "#{Study.count}".red
    puts "Experiences created: " + "#{Experience.count}".red
    puts "Applications created: " + "#{Application.count}".red

    puts ''
    puts "Time taken for each step:".green
    puts "Clearing database: " + "#{(t_stop_clear_db - t_clear_db).round(2)} seconds".red if clear_database
    puts "Fetching logos: " + "#{(t_stop_logos - t_logos).round(2)} seconds".red
    puts "Fetching profile pictures: " + "#{(t_stop_profile_pics - t_profile_pics).round(2)} seconds".red
    puts "Creating users: " + "#{(t_stop_create_users - t_create_users).round(2)} seconds".red
    puts "Creating profiles: " + "#{(t_stop_create_profiles - t_create_profiles).round(2)} seconds".red
    puts "Creating jobs: " + "#{(t_stop_create_jobs - t_create_jobs).round(2)} seconds".red
    puts "Creating studies: " + "#{(t_stop_create_studies - t_create_studies).round(2)} seconds".red
    puts "Creating experiences: " + "#{(t_stop_create_experiences - t_create_experiences).round(2)} seconds".red
    puts "Creating applications: " + "#{(t_stop_create_applications - t_create_applications).round(2)} seconds".red
    puts "Importing models: " + "#{(t_stop_import_models - t_import_models).round(2)} seconds".red
    puts "Assigning logos: " + "#{(t_stop_assign_logos - t_assign_logos).round(2)} seconds".red
    puts "Assigning profile pictures: " + "#{(t_stop_assign_profile_pics - t_assign_profile_pics).round(2)} seconds".red
    puts '---------------------------------'.green
    puts "TOTAL TIME: " + "#{(t_stop_import_models - t_clear_db).round(2)} seconds".red
  end

  def self.reindex
    puts ''
    puts "Reindexing models...".cyan
    t_reindex = Time.now
    Job.reindex
    puts "Reindexing completed!".green
    t_stop_reindex = Time.now
    puts "Time taken to reindex: " + "#{(t_stop_reindex - t_reindex).round(2)} seconds".red
  end

  def self.run
    puts ''
    puts 'Do you want to skip the seeding and only reindex the database for elasticsearch? ('.blue + 'y'.green + '/'.blue + 'n'.red + ')'.blue
    print '> '
    answer = gets.chomp

    SeederView.seeding if answer == 'n'
    SeederView.reindex
  end
end

SeederView.run
