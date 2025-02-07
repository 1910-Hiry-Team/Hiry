require_relative './sample_text_config'


module TestUsers
  TEST_USER_SEEKER = {
    email: 'test@seeker.com',
    password: '123456',
    password_confirmation: '123456',
    role: :jobseeker
  }

  TEST_USER_COMPANY = {
    email: 'test@company.com',
    password: '123456',
    password_confirmation: '123456',
    role: :company
  }

  TEST_JOBSEEKER = {
    first_name: 'Test',
    last_name: 'Seeker',
    phone_number: '1234567890',
    date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 65),
    skills: Faker::Job.key_skill,
    hobbies: Faker::Hobby.activity,
    location: 'Paris, France'
  }

  TEST_COMPANY = {
    name: 'Test Company',
    location: 'Paris, France',
    description: SampleText::COMPANY_DESCRIPTIONS.sample,
    industry: 'Test Industry',
    employee_number: 10
  }

  WEB_DEVELOPMENT_SAMPLE_JOB = {
    job_title: 'Web Developer',
    location: 'Paris, France',
  }
end
