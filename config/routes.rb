Rails.application.routes.draw do
  post 'survey', to: 'surveys#survey'
  get 'touchpoint', to: 'surveys#touchpoint'
end
