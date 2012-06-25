class CreateRawStats < ActiveRecord::Migration
  def change
    create_table :raw_stats do |t|
      t.integer :id
      t.text :headers
      t.text :params
      t.text :raw_post
      t.text :created_at
      t.integer :game_id
      t.string :file_name
      t.string :feed_type

      t.timestamps
    end
  end
end
