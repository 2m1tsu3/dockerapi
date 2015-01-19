require 'docker'
require 'json'
require 'mysql2'

Docker.url="http://127.0.0.1:4243/"

def convert(data)
    fields = {}
    fields['command'] = data['Command']
    fields['created'] = Time.at(data['Created'])
    fields['status'] = data['Status']
    fields['names'] = data['Names']
    fields['image'] = data['Image']
    fields['container_id'] = data['id']
    fields['ports'] = data['Ports']
    return fields
end

cons = Docker::Container.all(:all => true)
records = []
cons.each do |con|
    records.push(convert(con.info))
    puts convert(con.info)
end

client = Mysql2::Client.new(:host => 'localhost', :username => 'root', :password => 'uk-lab', :database => 'docker')

records.map { |con| client.query('REPLACE INTO container (' + con.keys.join(',') + ') VALUES ("' + con.values.join('","') + '")') };
