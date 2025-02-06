require_relative '../../config/seed_config'

require 'parallel'

class DbController
  # -------------------
  def self.clear_database
    models = [Application, Favorite, Job, Company, Experience, Study, User]
    Parallel.each(models, in_threads: SeedConfig::THREADS_TO_USE) do |model|
      model.connection.execute("TRUNCATE TABLE #{model.table_name} RESTART IDENTITY CASCADE")
    end
  end

  # -------------------
  def self.model_importer(model, model_to_import)
    model.import(model_to_import)
  end
end
