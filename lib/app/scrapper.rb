require 'nokogiri' 
require 'open-uri'  
require 'json'
require "google_drive"
require 'csv'

class Json

def get_townhall_email(townhall_url)
	townhall_page = Nokogiri::HTML(open(townhall_url))
	townhall_page.xpath("/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]").each do |node|
	  return node.text
	end
end

def get_townhall_list_and_url
	townhall_list_page = Nokogiri::HTML(open("https://annuaire-des-mairies.com/val-d-oise.html"))
	town_list = townhall_list_page.xpath("//td/p/a").map{|node| node.text}
	town_url = townhall_list_page.xpath("//td/p/a/@href").map{|node| "https://annuaire-des-mairies.com/#{node.text[2..-1]}"}
	return town_list.zip(town_url)
end

def get_email_list
	return get_townhall_list_and_url.map{|town, url| {town => get_townhall_email(url)}}
end

def save_as_json
  email_hash = []
  get_email_list.each do |i|
email_hash << i
File.open("db/email.json","w") do |f|
  f.write(email_hash.to_json)
end
  end
end

def save_as_spreadsheet
  session = GoogleDrive::Session.from_config("config.json")
  ws = session.spreadsheet_by_key("1Il-cReJk4sGRdeHGPVukt10t9VDwaj-_-Cenq6Og8RU").worksheets[0]
  k = 2
  ws[1, 1] = "Ville"
  ws[1, 2] = "Email"
  get_email_list.each do |i|
    ws[k, 1] = i.keys.join(', ')
    ws[k, 2] = i.values.join(', ')
    ws.save
    k += 1
end
end

def save_as_csv
  temp = get_email_list.map{|hash| hash.map{|k, v| [k, v]}}
  temp = temp.map { |data| data.join(",") }.join("\n")
  File.open("db/emails.csv", "w") do |csv|
    csv.write(temp)
  end
  end



def perform	
 puts get_email_list
 save_as_json
 save_as_spreadsheet
 save_as_csv
end


  
  
end
