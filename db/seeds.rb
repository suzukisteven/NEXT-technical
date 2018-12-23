# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

house = {}

ActiveRecord::Base.transaction do
  87.times do
    house['name'] = Faker::TwinPeaks.location
    house['address'] = Faker::Address.street_address
    house['rented'] = [true, false].sample
    House.create(house)
  end
end
