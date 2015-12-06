require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'pry'

require_relative 'models/contact'
also_reload 'models/contact'

before do
  contact_attributes = [
    { first_name: 'Eric', last_name: 'Kelly', phone_number: '1234567890' },
    { first_name: 'Adam', last_name: 'Sheehan', phone_number: '1234567890' },
    { first_name: 'Dan', last_name: 'Pickett', phone_number: '1234567890' },
    { first_name: 'Evan', last_name: 'Charles', phone_number: '1234567890' },
    { first_name: 'Faizaan', last_name: 'Shamsi', phone_number: '1234567890' },
    { first_name: 'Helen', last_name: 'Hood', phone_number: '1234567890' },
    { first_name: 'Corinne', last_name: 'Babel', phone_number: '1234567890' }
  ]

  @contacts = contact_attributes.map do |attr|
    Contact.new(attr)
  end
end

get '/' do
  redirect '/contacts/page/1'
end

get '/contacts/page/:num' do
  if params[:num].match(/^\d+$/)
    @page = params[:num].to_i
    contact_list = Contact.all
  else
    parsed_name = params[:num].match(/^(\d+)[_](\S+)_(\S+)/)
    @page = parsed_name[1].to_i
    @name = "#{parsed_name[2]}_#{parsed_name[3]}"
    contact_list = Contact.where(first_name: parsed_name[2], last_name: parsed_name[3])
  end
  @contacts = contact_list.limit(10).offset((@page.to_i - 1) * 10)
  @next_page = (contact_list.limit(10).offset((@page.to_i) * 10).length > 0)
  erb :index
end

get '/contacts/:id' do
  @contact = Contact.find_by(id: params[:id])
  erb :show
end

post '/contacts' do
  parsed_name = params[:name].match(/^(\S+)\s(\S+)/)
  if parsed_name
    redirect "/contacts/page/1_#{parsed_name[1]}_#{parsed_name[2]}"
  else
    status 404
    erb :error
  end
end

post '/contacts/new' do
  parsed_name = params[:add_name].match(/^(\S+)\s(\S+)/)
  if parsed_name
    Contact.create(first_name: parsed_name[1], last_name: parsed_name[2], phone_number: params[:phone_number])
    redirect '/'
  else
    status 404
    erb :error
  end
end
