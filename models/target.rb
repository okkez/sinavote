
class Target < Sequel::Model
  one_to_many :comments

  def rating
    0
  end
end
