class LinesController < ApplicationController
  # maybe someday add authentication
  skip_before_action :verify_authenticity_token

  # GET /lines
  def index
  end
end