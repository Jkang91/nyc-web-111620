class AddRewardsMemberToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :rewards_member, :boolean, default: false
  end
end
