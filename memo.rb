# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'cgi'

path = 'public/memo.json'

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

begin
  memos = read_json_memo(path)
rescue StandardError
  memos = { "0": { "title": 'ここはタイトル', "content": 'ここは内容' } }
  write_json_memo(path, memos)
end

get '/memos' do
  @memos = read_json_memo(path)
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

  memos = read_json_memo(path)

  array_keys = memos.keys
  max_number = array_keys.max.to_i
  memos[max_number + 1] = {
    'title' => title,
    'content' => content
  }

  write_json_memo(path, memos)

  redirect '/memos'
end

get '/memos/:key' do
  memos = read_json_memo(path)

  @key = params[:key]
  @memo = memos[@key]

  erb :display
end

get '/memos/:key/changes' do
  memos = read_json_memo(path)

  key = params[:key]

  @key = key
  @memo = memos[@key]

  erb :change
end

patch '/memos/:key/changes' do
  key = params[:key]
  title = params[:title]
  content = params[:content]

  memos = read_json_memo(path)

  memos[key] = { 'title' => title, 'content' => content }

  write_json_memo(path, memos)

  redirect "/memos/#{key}"
end

delete '/memos/:key/deletions' do
  key = params[:key]

  memos = read_json_memo(path)

  memos.delete(key)

  write_json_memo(path, memos)

  redirect '/memos'
end
