require 'open-uri'
require 'parallel'
require 'rainbow/refinement'
using Rainbow

require_relative 'seeder/app/views/seeder_view'

# -------------------
# Run the seeder
# -------------------
SeederView.run
