#!/usr/bin/env ruby
require 'rubygems'
require 'aws-sdk'

bucket_name = ARGV[0]

started = Time.now
puts "Beginning to update #{bucket_name} at #{started}"


s3 = AWS.s3
bucket = s3.buckets[bucket_name]

bucket.objects.each do |obj|
  name = obj.key.split('/')[-2,2].join('/')
  next if name =~ /\$folder\$/
  puts "[S3] #{name}"
  $PROGRAM_NAME = "[S3] #{name}"
  obj.copy_to(obj.key, :acl => :public_read, :cache_control => 'public, max-age=315576000', :content_type => obj.content_type)
end

puts "Completed run in #{Time.now - started} seconds"

__END__

# EXPORT AWS KEYS
source ~/.ec2/parentpins/set-aws
ruby bin/s3_cache_control.rb parentpins

# started run at 1:23