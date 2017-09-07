require 'validators/post_validator.rb'
require 'validators/user_validator.rb'
class PostsController < ApplicationController
  def create
    respond_to do |format|
      login = params[:post][:login] rescue nil
      if login.present?
        @user = User.find_by(login: login)
        if @user.blank?
          @user = User.new(login: login)
          user_validator = UserValidator.new(@user)
          if user_validator.valid?
            @user.save!(validate: false)
          else
            format.json {render json: user_validator.errors, status: 422}
            return false
          end
        end

        @post = @user.posts.build(post_params)
        post_validator = PostValidator.new(@post)
        if post_validator.valid?
          @post.save!(validate: false)
          format.json {render json: @post, status: 200}
        else
          format.json {render json: post_validator.errors, status: 422}
        end
      else
        login_error = {login: ["login is missing"]}
        format.json {render json: login_error, status: 422}
      end
    end
  end

  def get_top_posts
    respond_to do |format|
      if params[:top_count].present?
        @top_posts = Post.get_top_posts(params[:top_count].to_i)
        format.json {render json: @top_posts, status: 200}
      else
        format.json {render json: "top count is missing", status: 422}
      end
    end
  end

  def get_user_ips
    @user_ips_and_logins = Post.get_user_ips_and_logins
    render json: @user_ips_and_logins, status: 200
  end

  private
  def post_params
    params.require(:post).permit(:title, :content, :user_ip, :login)
  end
end
