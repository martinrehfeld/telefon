class CallsController < ApplicationController
  
  # GET /calls
  def index
    @call = Call.new(:origin => cookies[:last_call_origin])
    @include_history = true
  end

  # POST /calls
  def create
    @call = Call.new(params[:call])
    cookies[:last_call_origin] = { :value => @call.origin, :expires => 5.years.from_now }
    response = @call.dial

    if response[:status_code] == 200
      flash[:notice] = _('Call initiated.')
      redirect_to calls_url
    else
      raise "#{response[:status_string]} (#{response[:status_code]})"
    end
  rescue
    @call.errors.add_to_base "Exception: #{$!}" if @call.valid? # only if Sipgate API was actually touched
    render :action => :index
  end
  
  # (XHR) GET /calls/history
  def history
    @history = Call.history
    respond_to do |format|
      format.html # default 
      format.js   { render :partial => 'history' }
    end
  end

end
