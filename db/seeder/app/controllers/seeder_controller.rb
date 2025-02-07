require_relative '../../config/seed_config.rb'
require_relative '../../config/test_users_config'
require_relative './db_controller.rb'
require_relative '../../config/sample_text_config'

require 'parallel'

class SeederController
  # -------------------
  def self.create_test_users
    test_seeker = User.create!(TestUsers::TEST_USER_SEEKER)
    test_company = User.create!(TestUsers::TEST_USER_COMPANY)
    JobseekerProfile.create!(TestUsers::TEST_JOBSEEKER.merge(user_id: test_seeker.id))
    Company.create!(TestUsers::TEST_COMPANY.merge(user_id: test_company.id))
  end

  # -------------------

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
    DbController.model_importer(User, users_to_create)
    return users_to_create
  end

  # ---------------
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
          description: SampleText::COMPANY_DESCRIPTIONS.sample,
          industry: Faker::Company.industry,
          employee_number: rand(10..500)
        )
      end
    end
    DbController.model_importer(JobseekerProfile, jobseeker_profiles_to_create)
    DbController.model_importer(Company, companies_to_create)
  end

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
        missions: SampleText::MISSION_STATEMENTS.sample,
        contract: SeedConfig::CONTRACT_TYPES.sample,
        language: SeedConfig::REAL_LANGUAGES.sample,
        experience: SeedConfig::EXPERIENCE_LEVELS.sample,
        salary: rand(SeedConfig::SALARY_RANGE), # Adjust to fit your salary format
        company_id: companies.sample.id
      )
    end
    DbController.model_importer(Job, jobs_to_create)
  end
  # -------------------
  def self.create_test_jobs(companies)
    jobs_to_create = []
    Parallel.each(1.. SeedConfig::NUMBER_OF_TEST_JOBS, in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating jobs") do
      location = TestUsers::WEB_DEVELOPMENT_SAMPLE_JOB[:location]
      geo = Geocoder.search(location).first
      lat, lon = geo&.latitude, geo&.longitude

      jobs_to_create << Job.new(
        job_title: TestUsers::WEB_DEVELOPMENT_SAMPLE_JOB[:job_title],
        location: location,
        latitude: lat,
        longitude: lon,
        missions: SampleText::MISSION_STATEMENTS.sample,
        contract: SeedConfig::CONTRACT_TYPES.sample,
        language: SeedConfig::REAL_LANGUAGES.sample,
        experience: SeedConfig::EXPERIENCE_LEVELS.sample,
        salary: rand(SeedConfig::SALARY_RANGE), # Adjust to fit your salary format
        company_id: companies.sample.id
      )
    end
    DbController.model_importer(Job, jobs_to_create)
  end
  # -------------------
  def self.create_studies
    studies_to_create = []
    Parallel.each(User.where(role:0), in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating studies") do |user|
      rand(1.. SeedConfig::RANGE_OF_STUDIES).times do
        studies_to_create << Study.new(
          school: Faker::University.name,
          level: SeedConfig::STUDY_LEVELS.sample,
          diploma: Faker::Educator.course_name,
          start_date: Faker::Date.backward(days: 3650),
          end_date: Faker::Date.backward(days: 365),
          user_id: user.id
        )
      end
    end
    DbController.model_importer(Study, studies_to_create)
  end

  # -------------------
  def self.create_experiences
    experiences_to_create = []
    Parallel.each(User.where(role:0), in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating experiences") do |user|
      rand(1.. SeedConfig::RANGE_OF_EXPERIENCES).times do
        experiences_to_create << Experience.new(
          company: Faker::Company.name,
          job_title: Faker::Job.title,
          contrat: SeedConfig::JOB_TYPE.sample,
          missions: SampleText::MISSION_STATEMENTS.sample,
          description: SampleText::DESCRIPTIONS.sample,
          start_date: Faker::Date.backward(days: 2000),
          end_date: Faker::Date.backward(days: 365),
          user_id: user.id
        )
      end
    end
    DbController.model_importer(Experience, experiences_to_create)
  end

  # -------------------
  def self.create_applications(jobs)
    applications_to_create = []
    Parallel.each(User.where(role: 0), in_threads: SeedConfig::THREADS_TO_USE, progress: "Creating applications") do |user|
      rand(1..SeedConfig::RANGE_OF_APPLICATIONS).times do
      applications_to_create << Application.new(
        stage: SeedConfig::APPLICATION_STATUS.sample,
        match: [true, false].sample,
        user_id: user.id,
        job_id: jobs.sample[:id]
      )
      end
    end
    DbController.model_importer(Application, applications_to_create)
  end
end
