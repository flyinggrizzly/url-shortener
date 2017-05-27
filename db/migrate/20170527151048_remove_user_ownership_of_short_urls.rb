class RemoveUserOwnershipOfShortUrls < ActiveRecord::Migration[5.1]
  def change
    remove_column :short_urls, :user_id
  end
end
