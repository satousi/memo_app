# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'pg'
require 'cgi'
require 'dotenv'
Dotenv.load

before do
  @conn = PG::Connection.new(
    host: 'ik1-201-74253.vs.sakura.ne.jp',
    dbname: 'mydb',
    user: 'satousi',
    password: ENV['password'],
    port: 5432
  )
end

get '/memos' do
  @memos = @conn.exec('SELECT * FROM memos')
  erb :top
end

get '/memos/news' do
  erb :new
end

post '/memos/news' do
  title = params[:title]
  content = params[:content]

  @conn.exec_params('INSERT INTO memos (title, content) VALUES ($1, $2)', [title, content])

  redirect '/memos'
end

get '/memos/:id' do
  @id = params[:id]

  @memos = @conn.exec_params('SELECT * FROM memos WHERE id = $1', [@id])

  erb :display
end

get '/memos/:id/changes' do
  @id = params[:id]

  @memos = @conn.exec_params('SELECT * FROM memos WHERE id = $1', [@id])

  erb :change
end

patch '/memos/:id' do
  id = params[:id]
  title = params[:title]
  content = params[:content]

  @conn.exec_params('UPDATE memos SET title = $1, content = $2 WHERE id = $3', [title, content, id])

  redirect "/memos/#{id}"
end

delete '/memos/:id' do
  id = params[:id]

  @conn.exec_params('DELETE FROM memos WHERE id = $1', [id])

  redirect '/memos'
end
