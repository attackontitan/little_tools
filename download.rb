require 'require_relative'
require 'aws-sdk'
require 'yaml'

creds = YAML.load(File.read('creds.yml'))

Aws.config.update({
                    region: 'us-east-1',
                    credentials: Aws::Credentials.new(creds[ARGV[0]]['access_key_id'],
                                                      creds[ARGV[0]]['secret_access_key'])
})
client = Aws::S3::Client.new
resource = Aws::S3::Resource.new(client: client)

bucket_name  = creds[ARGV[0]]["download_bucket_name"]
list_with_prefix = resource.bucket(bucket_name).objects(prefix: ARGV[1])

if list_with_prefix.count == 1
  obj_key = list_with_prefix.first.key
  puts obj_key
  puts list_with_prefix.first.content_length
  if ARGV[2].nil?
    filename = "#{creds[ARGV[0]]["write_file_path"]}#{obj_key}"
    File.open(filename, 'wb') do |file|
      client.get_object({ bucket: bucket_name, key: obj_key }, target: file)
      system "tar -xzf #{filename} -C #{creds[ARGV[0]]['write_file_path']}"
    end
  end
elsif list_with_prefix.count == 0
  puts "No Files"
else
  list_with_prefix.each do |obj|
    puts "#{obj.key}-----------------#{obj.content_length}"
  end
end
