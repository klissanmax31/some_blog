require 'net/http'

creating_count = 200000
puts "создание #{creating_count} постов"
user_ips = []
user_logins = []
# 50 рандомных IP
50.times do |i|
  user_ips << "#{rand(256)}.#{rand(256)}.#{rand(256)}.#{rand(256)}"
end
# 100 логинов пользователей
100.times do |i|
  user_logins << "Username _#{i}"
end
creating_uri = URI.parse("http://localhost:3000/posts")
creating_http = Net::HTTP.new(creating_uri.host, creating_uri.port)
request = Net::HTTP::Post.new(creating_uri.request_uri, 'Content-Type' => 'application/json')
creating_count.times do |i|
  user_ip = user_ips[rand(50)]
  user_login = user_logins[rand(100)]

  request.body = {post: {login: user_login, user_ip: user_ip, title: "Post ##{i}", content: "Some post content ..."}}.to_json
  response = creating_http.request(request)

  if (i+1)%1000 == 0
    puts "Загружено #{i+1} постов"
  end
end

puts "оценка каждого третьего поста"
estimate_uri = URI.parse("http://localhost:3000/rates/evaluate_post")
estimate_http = Net::HTTP.new(estimate_uri.host, estimate_uri.port)
estimate_request = Net::HTTP::Post.new(estimate_uri.request_uri, 'Content-Type' => 'application/json')
Post.limit(creating_count).each_with_index do |post, index|
  if (index+1)%3 == 0
    estimate_request.body = {rate: {post_id: post.id, value: rand(2..5)}}.to_json
    response = estimate_http.request(estimate_request)
  end
  puts "оценено #{(index+1)/3} постов" if (index+1)%3000 == 0
end
