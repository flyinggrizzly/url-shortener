class CreateShortUrls < ActiveRecord::Migration[5.1]
  def change
    create_table :short_urls do |t|
      t.string     :url_alias
      t.text       :redirect
      t.references :user, foreign_key: true

      t.timestamps
    end
    add_index :short_urls, [:user_id, :url_alias, :redirect]
  end
end
