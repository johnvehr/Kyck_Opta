class RawStat < ActiveRecord::Base
  serialize :headers
  serialize :params
  # attr_accessible :created_at, :feed_type, :file_name, :game_id, :headers, :id, :params, :raw_post
end

# == Schema Information
#
# Table name: raw_stats
#
#  id         :integer         not null, primary key
#  headers    :text
#  params     :text
#  raw_post   :text
#  created_at :text
#  game_id    :integer
#  file_name  :string(255)
#  feed_type  :string(255)
