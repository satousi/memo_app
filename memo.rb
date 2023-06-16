# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

PATH = 'public/memo.json'

def read_json_memo(path)
  File.open(path) do |file|
    JSON.parse(file.read)
  end
end

def write_json_memo(path, memos)
  File.open(path, 'w') do |file|
    JSON.dump(memos, file)
  end
end

if File.exist?(PATH)
  memos = read_json_memo(PATH)
else
  write_json_memo(PATH, {})
end

get '/memos' do
  @memos = read_json_memo(PATH)
  erb :top
end

get '/memos/news' do
  erb :new
end

post '/memos/news' do
  memos = {}
  title = params[:title]
  content = params[:content]
  memos[title] = content

  memos = read_json_memo(PATH)

  memos[memos.keys.max.to_i + 1] = {
    'title' => title,
    'content' => content
  }

  write_json_memo(PATH, memos)

  redirect '/memos'
end

get '/memos/:key' do
  memos = read_json_memo(PATH)

  @key = params[:key]
  @memo = memos[@key]

  erb :display
end

get '/memos/:key/changes' do
  memos = read_json_memo(PATH)

  key = params[:key]

  @key = key
  @memo = memos[@key]

  erb :change
end

patch '/memos/:key/changes' do
  key = params[:key]
  title = params[:title]
  content = params[:content]

  memos = read_json_memo(PATH)

  memos[key] = { 'title' => title, 'content' => content }

  write_json_memo(PATH, memos)

  redirect "/memos/#{key}"
end

delete '/memos/:key/deletions' do
  key = params[:key]

  memos = read_json_memo(PATH)

  memos.delete(key)

  write_json_memo(PATH, memos)

  redirect '/memos'
end
