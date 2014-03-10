ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :milestones
    project.resources :iterations
  end
end
