ActionController::Routing::Routes.draw do |map|
  map.resources :projects do |project|
    project.resources :milestones
    project.resources :iterations
  end

  # Graph routes
  map.connect 'projects/:project_id/graphs/:action', :controller => :graph
end
