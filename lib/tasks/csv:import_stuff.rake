# require 'csv'

# namespace :csv do

#   desc "Import CSV Data"
#   task :import_stuff => :environment do

#     csv_file_path = 'lib/data/userscore.csv'

#     CSV.foreach(csv_file_path) do |row|
#       Subreddit.create!({
#         :name => row[0], 
#         :user => row[1],       
#       })
#       puts "Row added!"
#     end
#   end
# end