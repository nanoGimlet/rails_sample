class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if !user&.activated? && user&.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "アカウントを有効化しました。" # gitの練習のため
      redirect_to user
    else
      flash[:danger] = "無効なリンクです。再度取得してください。"
      redirect_to root_url
    end
  end
end
