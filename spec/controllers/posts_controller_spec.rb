require 'spec_helper'
require 'rails_helper'
describe PostsController, type: :controller do
  describe "create" do
    it "create post if login, title, content, user_ip params are present" do
      json_params = {:post =>
        {:login => "klissanmax31", :title => "Title post", :user_ip => "12.23.34.45", :content => "Some content ..."},
        :format => :json
      }
      post :create, :params => json_params
      parsed_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(parsed_response['id']).to_not be_nil
      expect(parsed_response['title']).to eq('Title post')
      expect(parsed_response['user_ip']).to eq('12.23.34.45')
      expect(parsed_response['content']).to eq('Some content ...')
    end

    it "failed create post if login is not present" do
      json_params = {:post =>
        {:title => "Title post", :user_ip => "12.23.34.45", :content => "Some content ..."},
        :format => :json
      }
      post :create, :params => json_params
      parsed_response = JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response['login']).to eq(["login is missing"])
    end

    it "failed create post if one of post's attributes is not present" do
      json_params = {:post =>
        {:login => "klissanmax31", :content => "Some content ..."},
        :format => :json
      }
      post :create, :params => json_params
      parsed_response = JSON.parse(response.body)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_response["title"]).to eq(["can't be blank"])
      expect(parsed_response["user_ip"]).to eq(["can't be blank"])
    end
  end

  describe "get_top_posts" do
    before(:all) do
      @posts = []
      @user = User.find_by(login: "rails_programmer")
      @user = User.create!(login: "rails_programmer") if @user.blank?
      5.times do |i|
        post = @user.posts.create!({
          :title => "Title post ##{i}",
          :user_ip => "12.23.34.45",
          :content => "Some content of post ##{i}..."
        })
        rate = rand(1..5)
        second_rate = rand(1..5)
        Post.evaluate_post post.rates.new(value: rate)
        Post.evaluate_post post.rates.new(value: second_rate)
        @posts << {post: post, average_rate: (rate+second_rate).to_f/2}
      end
      @posts.sort!{|pr1, pr2| pr2[:average_rate] <=> pr1[:average_rate]}
    end
    it "get top rate posts" do
      count = 3
      json_params = {:top_count => count, :format => :json}
      post :get_top_posts, :params => json_params
      parsed_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(parsed_response.length).to eq(count)
      expecting_result = @posts.map{|post| [post[:post].id, post[:average_rate]]}[0..count-1]
      expect(parsed_response.map{|rp| [rp["id"].to_i, rp["average_rate"].to_f]}).to eq(expecting_result)
    end

    it "get an empty array of response if no post is evaluated" do
      Rate.delete_all
      Post.update_all(average_rate: nil)
      count = 3
      json_params = {:top_count => count, :format => :json}
      post :get_top_posts, :params => json_params
      parsed_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(parsed_response.blank?).to be true
    end

    after(:all) do
      Rate.delete_all
      Post.delete_all
      User.delete_all
    end
  end
  describe "get_user_ips" do
    before(:all) do

    end
    it "get an empty array if posts do not exist" do
      post :get_user_ips
      parsed_response = JSON.parse(response.body)
      expect(response).to have_http_status(:ok)
      expect(parsed_response.blank?).to be true
    end

    it "get one group of logins with identical IP" do
      count = 3
      user_ip = "12.23.34.45"
      count.times do |i|
        json_params = {:post =>
          {:login => "username_#{i}", :title => "Title post ##{i}", :user_ip => user_ip, :content => "Some content ..."},
          :format => :json
        }
        post :create, :params => json_params
      end
      post :get_user_ips
      parsed_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(parsed_response.length).to eq(1)
      expect(parsed_response.first['logins'].length).to eq(count)
      expect(parsed_response.first['ip']).to eq(user_ip)
    end

    it "get several groups of logins with different IP" do
      user_ips = []
      count = 3
      count.times do |i|
        user_ip = "#{rand(256)}.#{rand(256)}.#{rand(256)}.#{rand(256)}"
        count.times do |n|
          json_params = {:post =>
            {:login => "username_#{n}", :title => "Title post ##{n}", :user_ip => user_ip, :content => "Some content ..."},
            :format => :json
          }
          post :create, :params => json_params
        end
        user_ips << user_ip
      end
      user_ips_length = user_ips.uniq.length
      distinct_ips_count = Post.select('distinct user_ip').count

      post :get_user_ips
      parsed_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(parsed_response.blank?).not_to be true
      expect(parsed_response.map{|pr| pr['logins'].length}.include?(0)).not_to be true
      expect(parsed_response.length).to eq(user_ips_length)
      expect(parsed_response.length).to eq(distinct_ips_count)
    end

    after(:each) do
      Rate.delete_all
      Post.delete_all
      User.delete_all
    end

  end
end
