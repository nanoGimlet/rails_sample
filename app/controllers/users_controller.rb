class UsersController < ApplicationController
  before_action :logged_in_user_check, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :correct_user_check,   only: [:edit, :update]
  before_action :admin_user_check,     only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    @micropost = current_user.microposts.build
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "メールを確認してアカウントを有効化してください。"
      redirect_to root_url
    else
      flash[:failure] = "メールを送信できませんでした。"
      render :'new'
    end
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      # 更新に成功した場合を扱う。
      flash[:success] = "プロフィールを更新しました。"
      redirect_to @user
    else
      flash[:failure] = "プロフィールの更新に失敗しました。"
      render :'edit'
    end
  end

  def destroy
    if User.find(params[:id]).destroy
      flash[:success] = "ユーザーを削除しました。"
      redirect_to users_url
    else
      flash[:failure] = "ユーザーの削除に失敗しました。"
      redirect_to users_url
    end
  end

  def following
    @title = :"Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = :"Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation,
                                   :unique_name)
    end

    # beforeアクション

    # 正しいユーザーかどうか確認
    def correct_user_check
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user_check
      redirect_to(root_url) unless current_user.admin?
    end
end
