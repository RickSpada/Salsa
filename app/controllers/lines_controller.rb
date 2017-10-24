class LinesController < ApplicationController
  # maybe someday add authentication
  skip_before_action :verify_authenticity_token

  # TODO DRY this up
  rescue_from ActionController::ParameterMissing do |e|
    render :json => { :errors => e.message }, :status => :bad_request
  end

  rescue_from StandardError do |e|
    render :json => { :errors => e.message }, :status => 413
  end

  # GET /lines
  def index
    params.require(:line_number)

    # Fetch the requested line number
    line = Lines::Get.call(params[:line_number])
    render({ :json => { line: line }, :status => 200 })
  end
end