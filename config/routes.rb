Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post '/posts', to: 'posts#create'
  post '/rates/evaluate_post', to: 'rates#evaluate_post'
  post '/posts/get_top_posts', to: 'posts#get_top_posts'
  post '/posts/get_user_ips', to: 'posts#get_user_ips'
end
