
class Comment < Sequel::Model
  plugin :timestamps, :update_on_create => true
  many_to_one :target

end
