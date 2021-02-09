class AddUserRefToMicroposts < ActiveRecord::Migration[5.2]
  def change
    add_reference :microposts, :micropost, foreign_key: true
  end
end
