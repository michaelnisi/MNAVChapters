
task :default => 'test'

desc "Run the MNAVChapters tests for iOS"
task :test do
    $ios_success = system("xctool -workspace MNAVChapters.xcworkspace -scheme MNAVChapters test -sdk iphonesimulator")
  puts "\033[0;31m! iOS unit tests failed" unless $ios_success
  if $ios_success
    puts "\033[0;32m** All tests executed successfully"
  else
    exit(-1)
  end
end

desc "Runs the specs [EMPTY]"
task :spec do
  # Provide your own implementation
end

desc "Release a new version of the Pod"
task :release do

  unless ENV['SKIP_CHECKS']
    if `git symbolic-ref HEAD 2>/dev/null`.strip.split('/').last != 'master'
      $stderr.puts "[!] You need to be on the `master' branch in order to be able to do a release."
      exit 1
    end

    if `git tag`.strip.split("\n").include?(spec_version)
      $stderr.puts "[!] A tag for version `#{spec_version}' already exists. Change the version in the podspec"
      exit 1
    end

    puts "You are about to release `#{spec_version}`, is that correct? [y/n]"
    exit if $stdin.gets.strip.downcase != 'y'
  end

  puts "* Running specs"
  sh "rake spec"

  puts "* Linting the podspec"
  sh "pod lib lint"

  sh "git tag -a #{spec_version} -m 'version #{spec_version}'"
  sh "git push origin master"
  sh "git push origin --tags"
  sh "pod push master #{podspec_path}"
end

def spec_version
  require 'rubygems'   
  require 'cocoapods'
  spec = Pod::Specification.from_file(podspec_path)
  spec.version
end

def podspec_path
  podspecs = Dir.glob('*.podspec')
  if podspecs.count == 1
    podspecs.first
  else
    raise "Could not select a podspec"
  end
end
