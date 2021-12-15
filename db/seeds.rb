require 'json'
require 'open-uri'
require 'faker'

puts 'Cleaning the DB'

Bookmark.destroy_all
List.destroy_all
Movie.destroy_all

puts 'Seeding movies. Lights! Camera!'

api_key = ENV['TMDB_KEY']

(1..5).each do |n|
  api_url = "https://api.themoviedb.org/3/movie/popular?api_key=#{api_key}&page=#{n}"
  raw_response = URI.open(api_url).read
  response = JSON.parse(raw_response)
  response['results'].each do |movie|
    poster_url = "https://image.tmdb.org/t/p/w500/#{movie['poster_path']}"
    movie = Movie.new(title: movie['title'],
                      overview: movie['overview'],
                      poster_url: poster_url,
                      rating: movie['vote_average'])
    file = URI.open(poster_url)
    movie.photo.attach(io: file, filename: 'poster.png', content_type: 'image/png')
    movie.save
  end
end

puts 'Movies seeded! Action!'
puts 'Creating beautiful lists!'

movies = Movie.all

10.times do
  list = List.create(
    name: Faker::Lorem.sentence(word_count: 3, supplemental: false, random_words_to_add: 4)
  )
  rand(2..5).times do
    bookmark = Bookmark.new(
      comment: Faker::Lorem.sentence(word_count: 3, supplemental: false, random_words_to_add: 4)
    )
    bookmark.list = list
    bookmark.movie = movies.sample
    bookmark.save
  end
end

puts 'All done!'
