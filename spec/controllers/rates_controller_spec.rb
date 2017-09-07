require 'spec_helper'
require 'rails_helper'
describe RatesController, type: :controller do
  describe "evaluate_post" do
    before(:each) do
      @user = User.find_by login: "klissanmax31"
      @user = User.create(:login => "klissanmax31") if @user.blank?

      @post = @user.posts.create({:user_id => @user.id, :title => "Title post #{Time.now.to_param}", :user_ip => "12.23.34.45", :content => "Some content create"})
    end

    it "evaluate post if rates doesn't exist before action" do
      post_id = @post.id
      rate = 4
      json_params = {:rate =>
        {:post_id => post_id, value: rate},
        :format => :json
      }
      post :evaluate_post, :params => json_params
      parsed_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(parsed_response).to_not be_nil
      expect(parsed_response.to_f).to eq(4)
    end

    it "evaluate post if rates exist before action" do
      @post.rates.create!([{value: 3}, {value: 2}])
      rate = 4
      json_params = {:rate =>
        {:post_id => @post.id, value: rate},
        :format => :json
      }
      post :evaluate_post, :params => json_params
      parsed_response = JSON.parse(response.body)
      average_rate = Post.find(@post.id).average_rate
      expect(average_rate).to eq(parsed_response.to_f)
      expect(response).to have_http_status(:ok)
    end
  end
end
