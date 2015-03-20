# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

user_infos = [
  { username: 'testuser', email: 'testuser@example.com', password: '!1Abcdef' },
  { username: 'testuser1', email: 'testuser1@example.com', password: '!1Abcdef' },
  { username: 'testuser2', email: 'testuser2@example.com', password: '!1Abcdef' }
]
user_infos.each do |user_info|
  @user = User.new(user_info)
  @user.save!
end

