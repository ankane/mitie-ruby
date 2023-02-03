require "bundler/gem_tasks"
require "rake/testtask"

task default: :test
Rake::TestTask.new do |t|
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
end

def download_file(file, sha256)
  require "open-uri"

  url = "https://github.com/ankane/ml-builds/releases/download/mitie-0.7/#{file}"
  puts "Downloading #{file}..."
  contents = URI.parse(url).read

  computed_sha256 = Digest::SHA256.hexdigest(contents)
  raise "Bad hash: #{computed_sha256}" if computed_sha256 != sha256

  dest = "vendor/#{file}"
  File.binwrite(dest, contents)
  puts "Saved #{dest}"
end

namespace :vendor do
  task :linux do
    download_file("libmitie.so", "07b241d857a4bcd7fd97b68a87ccb06fbab70bfc621ee25aa0ea6bd7f905c45c")
  end

  task :mac do
    download_file("libmitie.dylib", "8c4fdbe11ef137c401141242af8030628672d64589b5e63ba9c13b7162d29d6c")
    download_file("libmitie.arm64.dylib", "616117825ac8a37ec1f016016868e1d72a21e5f3a90cc6b0347d4ff9dbf98088")
  end

  task :windows do
    download_file("mitie.dll", "dfeaaf72b12c7323d9447275af16afe5a1c64096ec2f00d04cb50f518ca19776")
  end

  task all: [:linux, :mac, :windows]

  task :platform do
    if Gem.win_platform?
      Rake::Task["vendor:windows"].invoke
    elsif RbConfig::CONFIG["host_os"] =~ /darwin/i
      Rake::Task["vendor:mac"].invoke
    else
      Rake::Task["vendor:linux"].invoke
    end
  end
end
