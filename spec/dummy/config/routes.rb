Rails.application.routes.draw do

  # users for optimacms
  devise_for :cms_admin_users, Optimacms::Devise.config

  # usual

  devise_for :users

  get 'hello.html', to: 'my#hello', as: 'hello'


  # extend admin area
  scope '/'+Optimacms.main_namespace+'/'+Optimacms.admin_namespace, module: "optimacms" do
    namespace :admin do
      resources :news do
        collection do
          post 'search'
        end
      end
    end
  end


  # the last!!!
  mount Optimacms::Engine => '/'+Optimacms.main_namespace

  #
  root to: 'home#index'


  # all pages
  #scope module: 'optimacms' do
  #  match '*path', :to => 'pages#show', via: :all
  #end

  #, format: false
  # , constraints: -> (req) { !(req.fullpath =~ /^\/assets\/.*/) }
end
