class ApplicationController < ActionController::Base
  # Catch common parameter errors and return a clean 400
  rescue_from ActionController::ParameterMissing do |e|
    redirect_back fallback_location: root_path, alert: "Missing required parameter: #{e.param}"
  end
end
