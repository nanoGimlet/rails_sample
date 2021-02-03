class MicropostsController < ApplicationController
  before_action :logged_in_user_check, only: [:create, :destroy]
  before_action :correct_user_check,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    # @から始まり、半角英数またはアンダースコアが5回以上、15回以下の繰り返しにマッチ。大文字、小文字区別しない。
    re = /@([0-9a-z_]{1,15})/i
    # 投稿文に対して上記正規表現をマッチング
    reply_user_name = @micropost.content.match(re)

    # $1は正規表現の中の丸かっこの表現にマッチする内容が入る(つまりここでは一意ユーザ名)
    # マッチするものが無ければnil
    if reply_user_name
      # マッチした一意ユーザ名は小文字にしてから検索します
      reply_user = User.find_by(unique_name: reply_user_name.downcase)
      # 一意ユーザ名を持つ返信先ユーザが存在すればin_reply_toカラムにそのユーザIDをセット
      @micropost.in_reply_to = reply_user&.id
    end
    
    if @micropost.save
      flash[:success] = "マイクロポストを投稿しました。"
      redirect_to root_url
    else
      @feed_items = []
      flash[:failure] = "マイクロポストの投稿に失敗しました。"
      render :'home_pages/home'
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = "マイクロポストを削除しました。"
      redirect_to request.referrer || root_url
    else
      flash[:failure] = "マイクロポストの削除に失敗しました。"
      render :'home_pages/home'
    end
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture, :micropost_id)
    end

    def correct_user_check
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
