ActionController::Routing::Routes.draw do |map|

  map.calls          '',                  :controller => 'calls', :action => 'index', :conditions => { :method => :get }
  map.calls          '',                  :controller => 'calls', :action => 'create', :conditions => { :method => :post }
  map.call_history   'call-history',      :controller => 'calls', :action => 'history', :conditions => { :method => :get }
  map.call_behaviour 'call-behaviour.js', :controller => 'calls', :action => 'behaviour', :format => :js, :conditions => { :method => :get }

end
