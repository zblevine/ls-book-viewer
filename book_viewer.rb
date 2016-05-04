require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

helpers do
  def in_paragraphs(chptr)
    lines = chptr.split("\n\n")
    lines.each_with_index { |line, idx| line.prepend("<p id='#{idx}'>") << "</p>"}
    lines.join
  end

  def highlight(para, str)
    para.gsub(str, "<strong>" + str + "</strong>")
  end
end

before do
  @contents = File.readlines "data/toc.txt"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  chp_num = params[:number].to_i
  @title = "Chapter #{chp_num}: " + @contents[chp_num - 1]
  @chapter = File.read "data/chp#{chp_num}.txt"

  erb :chapter
end

get "/search" do
  if params[:query]
    par = []
    numbers = (1..12).select do |num|
      File.read("data/chp#{num}.txt").include?(params[:query])
    end
    numbers.each do |i|
      lines = File.read("data/chp#{i}.txt").split("\n\n")
      indices = (0...lines.size).select do |idx|
        lines[idx].include?(params[:query])
      end
      indices.each { |ndx| par << [i, ndx, lines[ndx]] }
    end

    @paragraphs = par
  end

  erb :search
end

not_found do
  redirect "/"
end
