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

  # возвращает все IP и логины постивших с данных IP пользователей
  def self.get_user_ips_and_logins
    b = Time.now
    # joins - долгая операция, поэтому извлечение постов и юзеров отдельно, потом бинарный поиск
    all_posts = Post.select("distinct on (user_ip, user_id) user_ip, user_id").order(:user_ip, :user_id)
    if all_posts.length > 0
      all_users = User.select(:id, :login).order(:id)
      login = Post.find_user_by_user_id(all_users, all_posts.first.user_id).login
      user_ips_with_logins = [{ip: all_posts.first.user_ip, logins: [login]}]
      if all_posts.length > 1
        all_posts[1..-1].each do |post|
          login = Post.find_user_by_user_id(all_users, post.user_id).login
          if user_ips_with_logins.last[:ip] == post.user_ip
            user_ips_with_logins.last[:logins] << login
          else
            user_ips_with_logins << {ip: post.user_ip, logins: [login]}
          end
        end
      end
      return user_ips_with_logins
    else
      return []
    end
  end

  # бинарный поиск в отсортированном массиве пользователей по id
  def self.find_user_by_user_id(users, user_id)
    lower_bound = 0
    upper_bound = users.length
    while lower_bound != upper_bound
      compared_value = (lower_bound + upper_bound) / 2
      if user_id == users[compared_value].id
        return users[compared_value]
      elsif user_id < users[compared_value].id
        upper_bound = compared_value
      else
        lower_bound = compared_value + 1
      end
    end
    return nil
  end
end
