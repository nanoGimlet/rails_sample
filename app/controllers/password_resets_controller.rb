class PasswordResetsController < ApplicationController
  before_action :valid_user_check, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "パスワードをリセットするためのメールを送信しました。"
      redirect_to root_url
    else
      flash.now[:danger] = "メールアドレスが間違っています。"
      render :new
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      # パスワードが空欄だった
      user.errors.add(:password, :blank)
      render :edit and return
    end

    if user.update_attributes(user_params)
      # 正常にパスワード変更できた
      log_in user
      flash[:success] = "パスワードがリセットされました。"
      redirect_to user
    else
      # パスワード変更に失敗した
      flash[:failure] = "パスワードのリセットに失敗しました。"
      render :edit
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    def user
      @user ||= User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user_check
      unless (user && user&.activated? && user&.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      if user.password_reset_expired?
        flash[:danger] = "有効期限が切れています。再度メールを送信してください。"
        redirect_to new_password_reset_url
      end
    end
end
