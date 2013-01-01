#!/usr/bin/env /usr/bin/ruby
require File.dirname(__FILE__) + "/../../config/environment"

# Simple script to import test photos from directory, process them and
# mark them all as moderated. Photos are imported as user test.
#
# TODO: propper handling of non-JPEG images within imported directory
# TODO: handle subdirectories

directory = ARGV[0]
if !directory
  abort("Usage: ./script/tools/import_test_directory.rb importDirectory")
end

if !File.directory?(directory)
  abort("Directory " + directory + " does not exist!")
end

user = User.find_by_login("test")
if !user
  abort("User test does not exist!")
end

pb = PhotoBatch.new
pb.name = 'Automatic import'
pb.user = user
pb.save

Dir.entries(directory).each do |s|
  if s != "." && s != ".."
    fullpath = directory+"/"+s
    fh = File.open(fullpath, "r")
    fn = Photo.handle_file( fh, user, pb )
    fh.close

    p = Photo.find_by_filename(fn)
    p.process
    p.update_status('available')
    p.save!
  end
end
