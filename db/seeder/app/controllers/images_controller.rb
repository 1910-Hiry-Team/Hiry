require_relative '../../config/seed_config.rb'
require_relative '../views/feedback_view.rb'

require 'open-uri'
require 'parallel'

class ImageController
  # -------------------
  def self.delete_cloudinary_images(prefix)
    begin
      Cloudinary::Api.delete_resources_by_prefix(prefix)
      FeedbackView.basic_success("Delete old images from Cloudinary!")
    rescue Cloudinary::Api::Error => e
      FeedbackView.basic_error("Deleting #{prefix} images from Cloudinary: #{e.message}")
    rescue Cloudinary::RateLimited => e
      FeedbackView.repeating_error("Rate limited by Cloudinary: #{e.message}", 3, 10)
    end
  end


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

      FeedbackView.basic_success("fetch #{urls.size} valid #{name.pluralize} from Cloudinary")
    rescue Cloudinary::Api::Error => e
      FeedbackView.basic_error("Fetching #{name.pluralize} from Cloudinary: #{e.message}")
    rescue Cloudinary::RateLimited => e
      FeedbackView.repeating_error("Rate limited by Cloudinary: #{e.message}", 3, 10)
    end
    urls
  end

  # -------------------
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
        FeedbackView.basic_error("Downloading image: #{e.message}")
      end
    end
    return dir_path
  end

  def self.delete_cache
    FileUtils.rm_rf(SeedConfig::TEMP_IMG_PATH) if Dir.exist?(SeedConfig::TEMP_IMG_PATH)
  end

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
