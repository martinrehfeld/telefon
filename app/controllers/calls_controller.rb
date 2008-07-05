class CallsController < ApplicationController
  
  # GET /calls
  def index
    @call = Call.new
  end

  # POST /calls
  def create
    @call = Call.new(params[:call])
    response = @call.dial

    if response[:status_code] == 200
      flash[:notice] = 'Anruf wurde abgesetzt.'
      redirect_to calls_url
    else
      raise response[:status_string]
    end
  rescue
    @call.errors.add_to_base "Ein Fehler ist aufgetreten: #{$!}"
    render :action => :index
  end

end
