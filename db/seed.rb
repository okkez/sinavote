require 'db/schema'
AppSchema.setup
require 'models/target'
require 'models/comment'

20.times do |n|
  t = Target.create(:uri => "http://example.com/#{n}")
  10.times do
    Comment.create(:target_id => t.id, :rating => rand(5)+1, :message => "hogehoge")
  end
end

