# Milestone and iterations routes
resources :projects do
  resources :milestones
  resources :iterations
end

# Graph routes
match 'projects/:project_id/graphs/:action', :controller => :graph
