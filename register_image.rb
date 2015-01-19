require 'docker'
require 'json'
require 'mysql2'
require 'digest/md5'

Docker.url="http://127.0.0.1:4243/"

def convert(data,i)
	fields = {}
        fields['image_created'] = Time.at(data['Created'])
        fields['parentid'] = data['ParentId']
        fields['repotags'] = data['RepoTags'][i]
        fields['size'] = data['Size']
        fields['virtualsize'] = data['VirtualSize']
        fields['image_id'] = data['id']
        return fields
end

images = Docker::Image.all(:all => true)
records = []
images.each do |image|
    if !image.info['RepoTags'].to_s.include?("<none>:<none>")
	image.info['RepoTags'].size().times{ |i|
            records.push(convert(image.info,i))
	}
    end
end
#records.each{|image| puts image}

client = Mysql2::Client.new(:host => 'localhost', :username => 'root', :password => 'uk-lab', :database => 'docker')

records.map { |image| client.query('REPLACE INTO images (' + image.keys.join(',') + ') VALUES ("' + image.values.join('","') + '")') };
