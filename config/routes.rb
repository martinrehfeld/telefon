ActionController::Routing::Routes.draw do |map|

  map.root :controller => "calls", :action => "new"
  map.resources :calls

end
