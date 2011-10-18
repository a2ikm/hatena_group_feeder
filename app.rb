require "open-uri"

module HatenaGroupFeeder
  class App < Sinatra::Base
    get '/' do
      "Hello, world!"
    end
    
    # 
    get '/:name.rdf' do
      @all_entries = []
      
      @name = params[:name]
      
      diarylist_rss = SimpleRSS.parse open("http://#{@name}.g.hatena.ne.jp/diarylist?mode=rss")
      diarylist_rss.entries.each do |diary|
        diary_rss = SimpleRSS.parse open("#{diary.link}rss")
        diary_rss.entries.each do |entry|
          entry[:datetime] = entry[:updated] || entry[:modified] || entry[:dc_date] || entry[:published] || entry[:pubDate]
          entry[:title] = "#{entry.title} | #{diary.title}"
          @all_entries << entry
        end
      end
      
      @all_entries.sort_by! { |entry| entry.datetime}
      @all_entries.reverse!
      
      erb :feed, :content_type => "application/rdf+xml"
    end
  end
end