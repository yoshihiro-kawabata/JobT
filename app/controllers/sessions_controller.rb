class SessionsController < ApplicationController
    skip_before_action :login_required, only: [:new, :create]

    def new
    end

    def create
        user = User.find_by(email: params[:session][:email].downcase)
        if user && user.authenticate(params[:session][:password])
          log_in(user)
          params[:session][:remember_me] == '1' ? remember(user) : forget(user)
          redirect_to  jobs_home_path
          flash[:notice] = 'ログインしました'
        else
          flash[:danger] = 'ログインに失敗しました'
          render :new
        end
    end

    def destroy
      log_out if logged_in? #この行を修正
      flash[:notice] = 'ログアウトしました'
      redirect_to  new_session_path
    end
end
