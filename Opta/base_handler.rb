
module Opta
  class HandlerException < ::Exception; end

  class BaseHandler
    attr_accessor :hash, :prev_hash, :game_id
    class_attribute :priority

    def self.set_priority new_val
      self.priority = new_val
    end
    set_priority 10

    def initialize game_id, hash, prev_hash
      self.game_id = game_id
      self.hash = hash
      self.prev_hash = prev_hash
    end

    def create_post message, user_type, tags=[]
      user = User.where(:kind => :system, :first_name => user_type).first
      if user
        post = Post.create! :text => message, :user => user
        tags.each do |t|
          if t.present?
            post.tags << t
            post.save!
          end
        end
        post
      end
    end

  end
end
