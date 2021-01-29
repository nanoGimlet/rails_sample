class PasswordResetsController < ApplicationController
  before_action :valid_user_check, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def user
    @user ||= User.find_by(email: params[:email])
  end

  def create
    @user ||= User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "パスワードをリセットするためのメールを送信しました。"
      redirect_to root_url
    else
      flash.now[:danger] = "メールアドレスが間違っています。"
      render :'new'
    end
  end

  def edit
  end

  def update
    unless params[:user][:password].empty?
      @user.erros.add(:password, :blank)
      render :'edit'
    end
    if @user.update_attributes(user_params)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "パスワードがリセットされました。"
      redirect_to @user
    else
      flash[:failure] = "パスワードのリセットに失敗しました。"
      render :'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # 正しいユーザーかどうか確認する
    def valid_user_check
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "有効期限が切れています。再度メールを送信してください。"
        redirect_to new_password_reset_url
      end
    end
end
