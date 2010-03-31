xml.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
xml.rss(:version => '2.0',
        "xmlns:dc" => "http://purl.org/dc/elements/1.1/",
        "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.channel do
    xml.title "sinavote comments"
    xml.link File.dirname(request.url)
    xml.language "ja-jp"
    xml.ttl "37"
    xml.description "comments of sinavote"
    xml.atom :link, :href => request.url, :rel => "self", :type => "application/rss+xml"

    @comments.each do |comment|
      xml.item do
        xml.title comment.target.uri
        xml.description comment.message + " | Rating:#{comment.rating}"
        xml.author comment.name
      end
    end
  end
end
