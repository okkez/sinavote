
class Comment < Sequel::Model
  plugin :timestamps, :update_on_create => true
  many_to_one :target

  def to_hash
    {
      :id         => id,
      :target_id  => target_id,
      :name       => name,
      :email      => email,
      :rating     => rating,
      :message    => message,
      :created_at => created_at,
      :updated_at => updated_at
    }
  end

  def to_hash_for_display
    {
      :target_id  => target_id,
      :name       => name,
      :rating     => rating,
      :message    => message,
      :created_at => created_at,
    }
  end
end
