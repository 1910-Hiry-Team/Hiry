require 'rainbow/refinement'
using Rainbow

class FeedbackView
  def self.basic_error(message, code = nil)
    puts "Error #{code unless code.nil?}: #{message}".red
  end

  def self.basic_success(message)
    puts "Executed #{message} successfully!".green
  end

  def self.basic_warning(message)
    puts "Warning: #{message}".yellow
  end

  def self.basic_info(message)
    puts message
  end

  def self.repeating_error(message, max_tries, cool_down, code = nil)
    tries = 0
    begin
      FeedbackView.basic_success("Action succeeded")
    rescue => e
      tries += 1
      FeedbackView.basic_error("#{message} (Attempt #{tries} failed: #{e.message})", code)
      if tries < max_tries
        puts "Retrying... in #{cool_down}".yellow
        sleep(cool_down)
        retry
      else
        FeedbackView.basic_error("Max tries reached. Action failed.", code)
      end
    end
  end
end
