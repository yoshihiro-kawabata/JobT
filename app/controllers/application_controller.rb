class ApplicationController < ActionController::Base
    include SessionsHelper
    before_action :login_required
    before_action :admin_required
    rescue_from ActiveRecord::RecordNotFound, with: :render_404
    rescue_from ActionController::RoutingError, with: :render_404
    rescue_from Exception, with: :render_500
    
    def render_404
      render template: 'errors/error_404', status: 404, layout: 'application', content_type: 'text/html'
    end
    
    def render_500
      render template: 'errors/error_500', status: 500, layout: 'application', content_type: 'text/html'
    end
    
    private

    def login_required
      redirect_to new_session_path, notice: 'ログインしてください。' unless current_user
    end

    def admin_required
      redirect_to jobs_home_path, notice: '権限がありません。' unless admin_user?
    end

end
