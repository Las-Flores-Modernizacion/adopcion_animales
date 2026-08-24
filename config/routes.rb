Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  scope controller: "sessions", path: "/auth" do
    match ":provider/callback", action: :create, via: %i[get post]
    get "failure", action: :failure
  end
  delete "/logout", to: "sessions#destroy"

  # Atajo de login solo para development: permite entrar como cualquier
  # cuenta existente (o crear una de prueba) sin pasar por Google OAuth,
  # ya que no hay credenciales reales configuradas en local. Nunca se monta
  # fuera de development (ver DevLoginController para el resguardo extra).
  if Rails.env.development?
    get "/dev_login", to: "dev_login#index", as: :dev_login
    post "/dev_login/nueva_cuenta", to: "dev_login#create_test_account", as: :dev_login_new_account
    post "/dev_login/:id", to: "dev_login#create", as: :dev_login_account
  end

  resources :reports, path: "reportes" do
    resources :sightings, only: [ :new, :create ], path: "avistamientos"
  end
  resources :animals, only: [ :index ], path: "animales"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"
end
