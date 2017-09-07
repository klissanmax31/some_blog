class Post < ApplicationRecord
  belongs_to :user
  has_many :rates

  # оценить и обновить среднюю оценку поста
  def self.evaluate_post(rate)
    rate.save
    average_rate = Rate.where(post_id: rate.post_id).average(:value)
    rate.post.update(average_rate: average_rate)
    return average_rate
  end

  # возвращает топ (N) постов, которые были оценены
  def self.get_top_posts(top_count)
    return Post.where.not(average_rate: nil).order(average_rate: :desc).limit(top_count)
  end

  def self.get_user_ips_and_logins
    all_posts = Post.select("distinct on (user_ip, user_id) user_ip, login").order(:user_ip, :user_id)

    logins_by_ips = []
    if all_posts.length > 0
      logins_by_ips  << {ip: all_posts.first.user_ip, logins: [all_posts.first.login]}
      if all_posts.length > 1
        all_posts[1..-1].each do |post|
          if post.user_ip == logins_by_ips.last[:ip]
            logins_by_ips.last[:logins] << post.login
          else
            logins_by_ips << {ip: post.user_ip, logins: [post.login]}
          end
        end
      end
    end
    return logins_by_ips
  end
end
