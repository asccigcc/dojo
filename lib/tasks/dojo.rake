namespace :dojo do
  desc "Import exercises from content/ into the database (idempotent upsert by slug)"
  task import: :environment do
    counts = Content::Importer.new.call
    puts "Dojo content imported: #{counts[:problems]} problems, #{counts[:warmups]} warm-up reps."
  end
end
