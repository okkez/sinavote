
class Comment < Sequel::Model
  many_to_one :target
end
