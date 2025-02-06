require_relative '../controllers/db_controller'
require_relative '../controllers/seeder_controller'
require_relative '../controllers/images_controller'

require 'rainbow/refinement'
using Rainbow

class SeederView
  def self.run
    SeederView.catch_env_errors
    puts ''
    puts 'Seeding v0.5.0'.green.underline.bold
    puts ''
    puts '-----------------'
    puts "| Seeding weight: " + "#{ENV['SEEDING_WEIGHT']}".green.bold
    puts "| Real cities: " + "#{ENV['USE_REAL_CITIES']}".green.bold
    puts "| Clear database: " + "#{ENV['CLEAR_DATABASE']}".green.bold
    puts "| Skip seeding: " + "#{ENV['SKIP_SEEDING']}".green.bold
    puts '-----------------'
    sleep(2)

    puts ''
    puts 'Starting seeding!'.magenta
    SeederView.new
    if ENV['SKIP_SEEDING'] == 'true'
      SeederView.reindex
    else
      SeederView.seeding
      SeederView.reindex
    end
  end

  private

  # -------------------
  # Error handling
  # -------------------
  def self.catch_env_errors
    required_env_vars = ['SEEDING_WEIGHT', 'USE_REAL_CITIES', 'CLEAR_DATABASE', 'SKIP_SEEDING']
    missing_env_vars = required_env_vars.select { |var| ENV[var].nil? }

    unless missing_env_vars.empty?
      puts "Error: Missing required environment variables: #{missing_env_vars.join(', ')}".red
      puts "The seeding has changed and now requires setting environment variables."
      puts "Go to your .env file and set the following variables:"
      puts "SEEDING_WEIGHT=light|medium|heavy".green
      puts "USE_REAL_CITIES=true|false".green
      puts "CLEAR_DATABASE=true|false".green
      puts "SKIP_SEEDING=true|false".green
      exit(1)
    end

    cloudinary_url = ENV['CLOUDINARY_URL']
    if cloudinary_url.nil?
      puts "Error: Missing CLOUDINARY_URL environment variable".red
      puts "Please set the CLOUDINARY_URL environment variable in your .env file".red
      exit(1)
    end

    mapbox_api_key = ENV['MAPBOX_API_KEY']
    if mapbox_api_key.nil?
      puts "Error: Missing MAPBOX_API_KEY environment variable".red
      puts "Please set the MAPBOX_API_KEY environment variable in your .env file".red
      puts "The script will work but features will be missing".red
    end
  end

  # -------------------
  # Seeding Start
  # -------------------
  def self.seeding
    @number_of_users = ENV['SEEDING_WEIGHT'] == 'light' ? rand(10..20) : ENV['SEEDING_WEIGHT'] == 'medium' ? rand(50..100) : rand(1000..2000)
    @number_of_jobs = ENV['SEEDING_WEIGHT'] == 'light' ? rand(5..10) : ENV['SEEDING_WEIGHT'] == 'medium' ? rand(25..50) : rand(400..600)
    @use_real_cities = ENV['USE_REAL_CITIES'] == 'true'
    @clear_database = ENV['CLEAR_DATABASE'] == 'true'

    if @clear_database
      puts ''
      t_clear_db = Time.now
      DbController.clear_database
      SeederController.create_test_users
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
    ImageController.delete_cloudinary_images('development')
    t_stop_delete_images = Time.now
    puts 'Old images deleted!'.green

    puts ''
    puts 'Logos'
    t_logos = Time.now
    logos = ImageController.fetch_cloudinary_urls('logos-company', 'logo')
    logo_cache_path = ImageController.download_images(logos)
    t_stop_logos = Time.now
    puts "#{logos.size} valid logos fetched!".green
    puts 'Added to cache'.green

    puts ''
    puts 'Profile Pictures'
    t_profile_pics = Time.now
    profile_pics = ImageController.fetch_cloudinary_urls('profile-pictures', 'profile picture')
    profile_pic_cache_path = ImageController.download_images(profile_pics)
    t_stop_profile_pics = Time.now
    puts "#{profile_pics.size} valid profile pictures fetched!".green
    puts 'Added to cache'.green

    puts ''
    puts 'Job images'
    t_job_images = Time.now
    job_images = ImageController.fetch_cloudinary_urls('job-job-images', 'job image')
    job_image_cache_path = ImageController.download_images(job_images)
    t_stop_job_images = Time.now
    puts 'Added to cache'.green

    # -------------------
    # Start creating the models
    # -------------------
    puts ''
    t_create_users = Time.now
    users = SeederController.create_users(@number_of_users)
    t_stop_create_users = Time.now
    puts 'Users created!'.green

    puts ''
    t_create_profiles = Time.now
    SeederController.create_profiles_and_companies(users, @use_real_cities)
    t_stop_create_profiles = Time.now
    puts 'Profiles and companies created!'.green

    puts ''
    t_create_jobs = Time.now
    SeederController.create_jobs(@number_of_jobs, @use_real_cities, Company.all)
    t_stop_create_jobs = Time.now
    puts 'Jobs created!'.green

    puts ''
    t_create_studies = Time.now
    SeederController.create_studies
    t_stop_create_studies = Time.now
    puts 'Studies created!'.green

    puts ''
    t_create_experiences = Time.now
    SeederController.create_experiences
    t_stop_create_experiences = Time.now
    puts 'Experiences created!'.green

    puts ''
    t_create_applications = Time.now
    SeederController.create_applications(Job.all)
    t_stop_create_applications = Time.now
    puts 'Applications created!'.green

    # -------------------
    # Assign images to models
    # -------------------
    puts ''
    t_assign_logos = Time.now
    ImageController.assign_images_from_cache(Company.all, logo_cache_path)
    t_stop_assign_logos = Time.now
    puts "Logos assigned!".green

    puts ''
    t_assign_profile_pics = Time.now
    ImageController.assign_images_from_cache(JobseekerProfile.all, profile_pic_cache_path)
    t_stop_assign_profile_pics = Time.now
    puts "Profile pictures assigned!".green

    puts ''
    t_assign_job_images = Time.now
    ImageController.assign_images_from_cache(Job.all, job_image_cache_path)
    t_stop_assign_job_images = Time.now
    puts "Job images assigned!".green

    puts ''
    ImageController.delete_cache
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
    puts "Clearing database: " + "#{(t_stop_clear_db - t_clear_db).round(2)} seconds".red if @clear_database
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
    puts "TOTAL TIME: " + "#{(t_stop_assign_job_images - t_clear_db).round(2)} seconds".red
  end


  # -------------------
  # Reindex models for elasticsearch
  # -------------------
  def self.reindex
    puts ''
    puts "Reindexing models...".cyan
    t_reindex = Time.now
    Job.reindex
    puts "Reindexing completed!".green
    t_stop_reindex = Time.now
    puts "Time taken to reindex: " + "#{(t_stop_reindex - t_reindex).round(2)} seconds".red
  end
end
