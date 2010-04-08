
class Target < Sequel::Model
  plugin :timestamps, :update_on_create => true
  one_to_many :comments, :order => [:created_at.desc]

  def rating_count(rating)
    Comment.filter(:target_id => id, :rating => rating).count
  end

  def recent_comments(count = 5)
    comments[0..count]
  end
end
