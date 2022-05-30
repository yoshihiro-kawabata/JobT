class ApplicationController < ActionController::Base
    include SessionsHelper
    before_action :login_required

    private

    def login_required
      redirect_to recipes_path unless current_user
    end
end
