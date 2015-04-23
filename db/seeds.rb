# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'CSV'

CSV.foreach(Dir.getwd + "/lib/data/userscore.csv") do |row|
	#@sub = Subreddit.find_by_name(row[1])
    Subreddit.create(:name => row[0], :users => row[1])
end