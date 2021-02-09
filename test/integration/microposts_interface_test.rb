require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type=file]'
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    # assert_select 'div#error_explanation'
    # 有効な送信
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    user_id = "michael"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, picture: picture, user_id: user_id} }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    micropost_cnt = @user.microposts.count
    micropost_check = micropost_cnt.to_s + " micropost"
    assert_match micropost_check, response.body
    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    micropost_not_cnt = 0
    micropost_not_check = micropost_not_cnt.to_s + " micropost"
    assert_match micropost_not_check, response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    micropost_one_cnt = 1
    micropost_one_check = micropost_one_cnt.to_s + " micropost"
    assert_match micropost_one_check, response.body
  end

  test "返信すると投稿者自身、返信先ユーザ、投稿者をフォローしているユーザのフィードだけにその投稿が表示されているか" do
    # テストユーザ取得
    #   michael (返信元ユーザ)
    #   archer  (返信先ユーザ)
    #   lana    (返信元ユーザをフォローしているユーザ)
    #   john    (返信元ユーザをフォローしていないユーザ)
    from_user   = users(:michael)
    to_user     = users(:archer)
    other_user1 = users(:lana)
    other_user2 = users(:john)
  
    # 返信先ユーザのunique_name取得
    unique_name = to_user.unique_name
  
    # 返信の内容
    content = "@#{unique_name} 結合テストで返信テスト"

    check_count = to_user.microposts.count
  
    # 返信元ユーザでログイン
    log_in_as(from_user)
  
    # 返信を投稿
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content, user_id: from_user.id } }
    end
  
    # 返信元ユーザのフィードに返信の投稿がある
    get root_path
    assert_equal from_user.microposts.first.content, content
  
    # 返信先ユーザのフィードに返信の投稿がある
    log_in_as(to_user)
    get root_path
    assert_equal to_user.feed.first.content, content
  
    # 返信元ユーザをフォローしているユーザのフィードに返信の投稿がある
    log_in_as(other_user1)
    get root_path
    assert_equal other_user1.feed.first.content, content
  
    # 返信元ユーザをフォローしていないユーザのフィードに返信の投稿がない
    log_in_as(other_user2)
    get root_path
    assert_equal other_user2.feed.count, 0
  end
end
