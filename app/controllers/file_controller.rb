class FileController < ApplicationController
  # maybe someday add authentication
  skip_before_action :verify_authenticity_token

  rescue_from ActionController::ParameterMissing do |e|
    render_failure(e.message, :bad_request)
  end

  rescue_from StandardError do |e|
    render_failure(e.message, :bad_request)
  end

  # POST /file
  def create
    params.require(:file_name)

    # process the file, if an error occurs it will be rescued above
    Files::Process.call(params[:file_name])
    render({ :json => nil, :root => true, :status => 200 })
  end

  def render_failure(errors, status)
    render :json => { :errors => errors }, :status => status
  end
end