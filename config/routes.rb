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

  # Atajo de login solo para development: entrar como cualquier email
  # visitando /dev_login/:email (se crea la cuenta si no existe), sin pasar
  # por Google OAuth ya que no hay credenciales reales configuradas en local.
  # Nunca se monta fuera de development (ver DevLoginController para el
  # resguardo extra).
  if Rails.env.development?
    get "/dev_login/:email", to: "dev_login#show", constraints: { email: /[^\/]+/ }, as: :dev_login
  end

  resources :reports, path: "reportes" do
    resources :sightings, only: [ :new, :create ], path: "avistamientos"
    resources :fosterings, only: [ :new, :create ], path: "transito"
    resources :adoptions, only: [ :new, :create ], path: "adopcion"
    member do
      patch :found, path: "encontrado"
      patch :approve_adoption, path: "aprobar-adopcion"
      patch :reject_adoption, path: "rechazar-adopcion"
    end
    collection do
      get :adoption_requests, path: "solicitudes-adopcion"
    end
  end
  resources :animals, only: [ :index ], path: "animales"
  resource :profile, only: [ :edit, :update ], path: "perfil"

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "pages#home"
end
