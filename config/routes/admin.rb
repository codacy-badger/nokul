# frozen_string_literal: true

require 'sidekiq/web'

authenticate :user do
  mount Sidekiq::Web, at: 'sidekiq'
  mount PgHero::Engine, at: 'postgres'
end

namespace :admin do
  # Location Management
  resources :countries do
    resources :cities, except: [:index] do
      resources :districts, except: %i[show index] do
      end
    end
  end

  # Other References
  resources :high_school_types, except: :show
  resources :assessment_methods, except: :show
  resources :document_types, except: :show
  resources :evaluation_types, except: :show
  resources :languages, except: :show
  resources :titles, except: :show
end
