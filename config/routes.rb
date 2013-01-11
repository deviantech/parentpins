ParentPins::Application.routes.draw do
  match "users/edit" => redirect('/profiles/account')
  devise_for :users

  resources :boards
  resources :pins do
    member do 
      post 'add_comment'
    end
  end

  # Pretty URLs for pin subtypes
  match '/articles' => 'pins#index',  :kind => 'article',   :as => 'articles'
  match '/gifts'    => 'pins#index',  :kind => 'gift',      :as => 'gifts'
  match '/ideas'    => 'pins#index',  :kind => 'idea',      :as => 'ideas'

  match '/pins/category/:category_id' => 'pins#index',  :as => 'pins_category'

  
  resources :profiles do
    member do
      get 'activity'
      get 'pins'
      get 'likes'
      get 'boards'
      get 'followers'
      get 'following'
      get 'boards/:board_id' => 'profiles#board', :as => 'board'
      get 'account'
    end
  end
  
  root :to => 'pins#index'
  
  resource :feedback, :only => [:new, :create]
  
  match '/about' => 'front#about'
  match '/legal' => 'front#legal'
  match '/privacy' => 'front#privacy'
end
