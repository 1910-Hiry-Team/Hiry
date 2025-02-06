require 'open-uri'
require 'parallel'
require 'rainbow/refinement'
using Rainbow

puts 'Seeding v0.4.7'.green # For Debug purposes to be sure you're in the right file

# -------------------
# Initial setup
# -------------------
module SeedConfig
  RANGE_OF_STUDIES = 3
  RANGE_OF_EXPERIENCES = 3
  RANGE_OF_APPLICATIONS = 5

  SALARY_RANGE = 30000..60000

  THREADS_TO_USE = 4
  IMAGE_BATCH_SIZE = 20

  TEMP_IMG_PATH = 'app/assets/images/tmp_images/'

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
  def self.clear_database
    models = [Application, Favorite, Job, Company, Experience, Study, User]
    Parallel.each(models, in_threads: SeedConfig::THREADS_TO_USE) do |model|
      model.connection.execute("TRUNCATE TABLE #{model.table_name} RESTART IDENTITY CASCADE")
    end
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
    Parallel.each(1..number_of_users, in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating users") do
      users_to_create << User.new(
      email: Faker::Internet.unique.email,
      password: '123456',
      password_confirmation: '123456',
      role: [:jobseeker, :company].sample
      )
    end
    DbHandler.model_importer(User, users_to_create)
    return users_to_create
  end

  # -------------------
  # Create profiles and companies
  # -------------------
  def self.create_profiles_and_companies(users, use_real_cities)
    jobseeker_profiles_to_create = []
    companies_to_create = []
    Parallel.each(users, in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating profiles and companies") do |user|
      location = use_real_cities ? SeedConfig::REAL_CITIES.sample : "#{Faker::Address.city}, #{Faker::Address.country}"

      if user.jobseeker?
        jobseeker_profiles_to_create << JobseekerProfile.new(
          user_id: user.id,
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name,
          phone_number: Faker::PhoneNumber.phone_number,
          date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
          skills: Faker::Job.key_skill, hobbies: Faker::Hobby.activity,
          location: location
        )
      else
        companies_to_create << Company.new(
          user_id: user.id,
          name: Faker::Company.name,
          location: location,
          description: Faker::Company.catch_phrase,
          industry: Faker::Company.industry,
          employee_number: rand(10..500)
        )
      end
    end
    DbHandler.model_importer(JobseekerProfile, jobseeker_profiles_to_create)
    DbHandler.model_importer(Company, companies_to_create)
  end

  # ---------------------------
  # Create jobs
  # ---------------------------
  def self.create_jobs(number_of_jobs, use_real_cities, companies)
    jobs_to_create = []
    Parallel.each(1..number_of_jobs, in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating jobs") do
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
        company_id: companies.sample.id
      )
    end
    DbHandler.model_importer(Job, jobs_to_create)
  end

  # -------------------
  # Create studies
  # -------------------
  def self.create_studies
    studies_to_create = []
    Parallel.each(User.where(role:0), in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating studies") do |user|
      rand(1.. SeedConfig::RANGE_OF_STUDIES).times do
        studies_to_create << Study.new(
          school: Faker::University.name,
          level: ["Bachelor's", "Master's", "PhD"].sample,
          diploma: Faker::Educator.course_name,
          start_date: Faker::Date.backward(days: 3650),
          end_date: Faker::Date.backward(days: 365),
          user_id: user.id
        )
      end
    end
    DbHandler.model_importer(Study, studies_to_create)
  end

  # -------------------
  # Create experiences
  # -------------------
  def self.create_experiences
    experiences_to_create = []
    Parallel.each(User.where(role:0), in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating experiences") do |user|
      rand(1.. SeedConfig::RANGE_OF_EXPERIENCES).times do
        experiences_to_create << Experience.new(
          company: Faker::Company.name,
          job_title: Faker::Job.title,
          contrat: ["Full-time", "Part-time", "Contract"].sample,
          missions: Faker::Lorem.sentence(word_count: 10),
          description: Faker::Lorem.paragraph,
          start_date: Faker::Date.backward(days: 2000),
          end_date: Faker::Date.backward(days: 365),
          user_id: user.id
        )
      end
    end
    DbHandler.model_importer(Experience, experiences_to_create)
  end

  # -------------------
  # Create applications
  # -------------------
  def self.create_applications(jobs)
    applications_to_create = []
    Parallel.each(User.where(role: 0), in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating applications") do |user|
      rand(1..SeedConfig::RANGE_OF_APPLICATIONS).times do
      applications_to_create << Application.new(
        stage: ["Applied", "Interviewing", "Hired", "Rejected"].sample,
        match: [true, false].sample,
        user_id: user.id,
        job_id: jobs.sample[:id]
      )
      end
    end
    DbHandler.model_importer(Application, applications_to_create)
  end
end

class ImageHandler
  # -------------------
  # Delete Cloudinary images
  # -------------------
  def self.delete_cloudinary_images(prefix)
    begin
      Cloudinary::Api.delete_resources_by_prefix(prefix)
      puts "Deleted old images from Cloudinary!".green
    rescue Cloudinary::Api::Error => e
      puts "Error deleting #{prefix} images from Cloudinary: #{e.message}".red
    rescue Cloudinary::RateLimited => e
      puts "Rate limited by Cloudinary: #{e.message}".red
    end
  end


  # -------------------
  # Fetch Cloudinary images
  # -------------------
  def self.fetch_cloudinary_urls(prefix, name)
    urls = []
    next_cursor = nil
    begin
      loop do
        # Fetch resources from Cloudinary
        response = Cloudinary::Api.resources(
          type: 'upload',
          prefix: prefix,
          max_results: 100,
          next_cursor: next_cursor
        )

        # Collect URLs for valid resources
        Parallel.each(response['resources'], in_threads: SeedConfig::THREADS_TO_USE, progress: "Fetching Cloudinary URLs") do |resource|
          urls << Cloudinary::Utils.cloudinary_url(resource['public_id'])
        end

        # Check for the next page of results
        next_cursor = response['next_cursor']
        break unless next_cursor
      end

      puts "#{urls.size} valid #{name.pluralize} fetched from Cloudinary!".green
    rescue Cloudinary::Api::Error => e
      puts "Error fetching #{name.pluralize} from Cloudinary: #{e.message}".red
    rescue Cloudinary::RateLimited => e
      puts "Rate limited by Cloudinary: #{e.message}".red
    end
    urls
  end

  def self.download_images(links)
    dir_path = nil
    FileUtils.mkdir_p(SeedConfig::TEMP_IMG_PATH) unless Dir.exist?(SeedConfig::TEMP_IMG_PATH)
    Parallel.each(links, in_threads: SeedConfig::THREADS_TO_USE, progress: "Downloading images to cache") do |url|
      file_path = File.join(SeedConfig::TEMP_IMG_PATH, url)
      dir_path = File.dirname(file_path)

      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

      begin
        File.open(file_path, 'wb') { |file| file.write(URI.open(url).read) }
      rescue Errno::ENOENT => e
        puts "Error downloading image #{url}: #{e.message}".red
      end
    end
    return dir_path
  end

  def self.delete_cache
    FileUtils.rm_rf(SeedConfig::TEMP_IMG_PATH) if Dir.exist?(SeedConfig::TEMP_IMG_PATH)
  end

  # -------------------
  # Assign images to models
  # -------------------
  def self.assign_images_from_cache(records, cache_dir)
    image_files = Dir.glob("#{cache_dir}/*")
    Parallel.each(records, in_threads: SeedConfig::THREADS_TO_USE, progress: "Assigning images") do |record|
      next if image_files.empty?

      image_path = image_files.sample
      record.photo.attach(io: File.open(image_path), filename: "#{File.basename(image_path)}_#{Date.today}_#{Time.now}")
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
    puts '1. '.red + 'Light' + ' (20s)'.green
    puts '2. '.red + 'Medium' + ' (60s)'.yellow
    puts '3. '.red + 'Heavy' + ' (900s)'.red
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
      puts 'Heavy seeding Selected'.yellow
      puts "This can be pretty CPU intensive. This will use #{SeedConfig::THREADS_TO_USE} threads".yellow
      puts 'Do you really want to proceed? ('.yellow + 'y'.green + '/'.yellow + 'n'.red + ')'.yellow
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
      t_clear_db = Time.now
      DbHandler.clear_database
      SeederHandler.create_test_users
      puts "Database cleared!".green
      t_stop_clear_db = Time.now
    end

    # -------------------
    # Cloudinary image fetching
    # And image caching
    # -------------------
    puts ''
    puts 'Deleting old images from Cloudinary'.yellow
    t_delete_images = Time.now
    ImageHandler.delete_cloudinary_images('development')
    t_stop_delete_images = Time.now
    puts 'Old images deleted!'.green

    puts ''
    puts 'Logos'
    t_logos = Time.now
    logos = ImageHandler.fetch_cloudinary_urls('logos-company', 'logo')
    logo_cache_path = ImageHandler.download_images(logos)
    t_stop_logos = Time.now
    puts "#{logos.size} valid logos fetched!".green
    puts 'Added to cache'.green

    puts ''
    puts 'Profile Pictures'
    t_profile_pics = Time.now
    profile_pics = ImageHandler.fetch_cloudinary_urls('profile-pictures', 'profile picture')
    profile_pic_cache_path = ImageHandler.download_images(profile_pics)
    t_stop_profile_pics = Time.now
    puts "#{profile_pics.size} valid profile pictures fetched!".green
    puts 'Added to cache'.green

    puts ''
    puts 'Job images'
    t_job_images = Time.now
    job_images = ImageHandler.fetch_cloudinary_urls('job-images', 'job image')
    job_image_cache_path = ImageHandler.download_images(job_images)
    t_stop_job_images = Time.now
    puts 'Added to cache'.green

    # -------------------
    # Start creating the models
    # -------------------
    puts ''
    t_create_users = Time.now
    users = SeederHandler.create_users(number_of_users)
    t_stop_create_users = Time.now
    puts 'Users created!'.green

    puts ''
    t_create_profiles = Time.now
    SeederHandler.create_profiles_and_companies(users, use_real_cities)
    t_stop_create_profiles = Time.now
    puts 'Profiles and companies created!'.green

    puts ''
    t_create_jobs = Time.now
    SeederHandler.create_jobs(number_of_jobs, use_real_cities, Company.all)
    t_stop_create_jobs = Time.now
    puts 'Jobs created!'.green

    puts ''
    t_create_studies = Time.now
    SeederHandler.create_studies
    t_stop_create_studies = Time.now
    puts 'Studies created!'.green

    puts ''
    t_create_experiences = Time.now
    SeederHandler.create_experiences
    t_stop_create_experiences = Time.now
    puts 'Experiences created!'.green

    puts ''
    t_create_applications = Time.now
    SeederHandler.create_applications(Job.all)
    t_stop_create_applications = Time.now
    puts 'Applications created!'.green

    # -------------------
    # Assign images to models
    # -------------------
    puts ''
    t_assign_logos = Time.now
    ImageHandler.assign_images_from_cache(Company.all, logo_cache_path)
    t_stop_assign_logos = Time.now
    puts "Logos assigned!".green

    puts ''
    t_assign_profile_pics = Time.now
    ImageHandler.assign_images_from_cache(JobseekerProfile.all, profile_pic_cache_path)
    t_stop_assign_profile_pics = Time.now
    puts "Profile pictures assigned!".green

    puts ''
    t_assign_job_images = Time.now
    ImageHandler.assign_images_from_cache(Job.all, job_image_cache_path)
    t_stop_assign_job_images = Time.now
    puts "Job images assigned!".green

    puts ''
    ImageHandler.delete_cache
    puts "Cache deleted!".green

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
    puts "Deleting images: " + "#{(t_stop_delete_images - t_delete_images).round(2)} seconds".red
    puts "Fetching logos: " + "#{(t_stop_logos - t_logos).round(2)} seconds".red
    puts "Fetching profile pictures: " + "#{(t_stop_profile_pics - t_profile_pics).round(2)} seconds".red
    puts "Fetching job images: " + "#{(t_stop_job_images - t_job_images).round(2)} seconds".red
    puts "Creating users: " + "#{(t_stop_create_users - t_create_users).round(2)} seconds".red
    puts "Creating profiles and companies: " + "#{(t_stop_create_profiles - t_create_profiles).round(2)} seconds".red
    puts "Creating jobs: " + "#{(t_stop_create_jobs - t_create_jobs).round(2)} seconds".red
    puts "Creating studies: " + "#{(t_stop_create_studies - t_create_studies).round(2)} seconds".red
    puts "Creating experiences: " + "#{(t_stop_create_experiences - t_create_experiences).round(2)} seconds".red
    puts "Creating applications: " + "#{(t_stop_create_applications - t_create_applications).round(2)} seconds".red
    puts "Assigning logos: " + "#{(t_stop_assign_logos - t_assign_logos).round(2)} seconds".red
    puts "Assigning profile pictures: " + "#{(t_stop_assign_profile_pics - t_assign_profile_pics).round(2)} seconds".red
    puts "Assigning job images: " + "#{(t_stop_assign_job_images - t_assign_job_images).round(2)} seconds".red
    puts '---------------------------------'.green
    puts "TOTAL TIME: " + "#{(t_stop_assign_profile_pics - t_clear_db).round(2)} seconds".red
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
