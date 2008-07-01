class CallsController < ApplicationController
  
  # GET /calls/new
  def new
    @call = Call.new
    # render default template
  end

  # POST /calls
  def create(call_attrs = params[:call])
    @call = Call.new(call_attrs)
    response = Sipgate.instance.voice_call(@call.origin,@call.destination)
    if response[:status_code] == 200
      flash[:notice] = 'Anruf wurde abgesetzt.'
      redirect_to new_call_url
    else
      raise response[:status_string]
    end
  rescue
    @error_message = "Ein Fehler ist aufgetreten: #{$!.message}."
    render :action => :new
  end

end
