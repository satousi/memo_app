# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

def json_memo_read
  open('public/memo.json') do |file|
    JSON.parse(file.read)
  end
end

def json_memo_write(json_memos)
  open('public/memo.json', 'w') do |file|
    JSON.dump(json_memos, file)
  end
end

get '/memos' do
  json_memos = json_memo_read

  @title = ''
  json_memos.each do |key, memo|
    @title += '<tr>'
    @title += "<td><a href=\"/memos/#{key}\">#{memo['title']}</a></td>"
    @title += "</tr>\n"
  end
  erb :top
end

get '/memos/news' do
  erb :new
end

post '/memos/news' do
  memos = {}
  title = CGI.escapeHTML(params[:title])
  content = CGI.escapeHTML(params[:content])
  memos[title] = content

  json_memos = json_memo_read

  array_memos = json_memos.keys
  max_number = array_memos.max.to_i
  json_memos[max_number + 1] = {
    'title' => title,
    'content' => content
  }

  json_memo_write(json_memos)

  redirect '/memos'
end

get '/memos/:key' do
  json_memos = json_memo_read

  @key = params[:key]
  @title = json_memos[@key]['title']
  @content = json_memos[@key]['content']

  erb :display
end

get '/memos/:key/changes' do
  json_memos = json_memo_read

  key = params[:key]

  @key = key
  @title = json_memos[key]['title']
  @content = json_memos[key]['content']

  erb :change
end

patch '/memos/:key/changes' do
  key = params[:key]
  title = params[:title]
  content = params[:content]

  json_memos = json_memo_read

  json_memos[key] = { 'title' => title, 'content' => content }

  json_memo_write(json_memos)

  redirect "/memos/#{key}"
end

delete '/memos/:key/deletions' do
  key = params[:key]

  json_memos = json_memo_read

  json_memos.delete(key)

  json_memo_write(json_memos)

  redirect '/memos'
end
