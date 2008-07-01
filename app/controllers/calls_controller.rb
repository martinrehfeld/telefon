class CallsController < ApplicationController
  
  # GET /calls/new
  def new
    @call = Call.new
    # render default template
  end

  # POST /calls
  def create(call_attrs = params[:call])
    response = Sipgate.instance.voice_call(nil,call_attrs[:destination])
    if response[:status_code] == 200
      flash[:notice] = 'Anruf wurde abgesetzt.'
      redirect_to new_call_url
    else
      @error_message = "Ein Fehler ist aufgetreten: #{response[:status_string]}."
      @call = Call.new(call_attrs)
      render :action => :new
    end
  end

end
