require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

def download_file(file)
  require "open-uri"

  url = "https://github.com/ankane/ml-builds/releases/download/mitie-0.7/#{file}"
  puts "Downloading #{file}..."
  dest = "vendor/#{file}"
  File.binwrite(dest, URI.open(url).read)
  puts "Saved #{dest}"
end

namespace :vendor do
  task :linux do
    download_file("libmitie.so")
  end

  task :mac do
    download_file("libmitie.dylib")
    download_file("libmitie.arm64.dylib")
  end

  task :windows do
    download_file("mitie.dll")
  end

  task all: [:linux, :mac, :windows]
end
