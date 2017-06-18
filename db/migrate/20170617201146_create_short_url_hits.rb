class CreateShortUrlHits < ActiveRecord::Migration[5.1]
  def change
    create_table :short_url_hits do |t|
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end
    add_reference :short_url_hits, :short_url, index:       true,
                                               foreign_key: true
  end
end
