class EmailsController < ApplicationController

  skip_before_action :verify_authenticity_token, :only => %w(create)
  skip_before_action :login_required, :only => %w(create)

  before_action :verify_server_can_send_email, :only => %w(create)

  def create
    begin
      body_string = request.body.read
      # Make sure that the request body can be parsed
      ActiveSupport::JSON.decode(body_string)

      Resque.enqueue(InboundEmailProcessor, body_string)
      render :nothing => true
    rescue MultiJson::DecodeError
      render :text => "Request body must be a JSON hash", :status => 400
    end
  end

  private

  def verify_server_can_send_email
    unless Server.find_by(key: params[:key])
      render :text => "Your server did not provide a valid key to post messages.", :status => 403
    end
  end
end
