module Salus
  class Repo
    attr_reader :path_to_repo

    IMPORTANT_FILES = [
      # Ruby
      { handle: :gemfile, filename: 'Gemfile' },
      { handle: :gemfile_lock, filename: 'Gemfile.lock' },
      { handle: :ruby_version, filename: '.ruby-version' },
      # JS
      { handle: :package_json, filename: 'package.json' },
      { handle: :package_lock_json, filename: 'package-lock.json' },
      { handle: :yarn_lock, filename: 'yarn.lock' },
      { handle: :npmrc, filename: '.npmrc' },
      # Go
      # https://go.googlesource.com/proposal/+/master/design/24301-versioned-go.md#compatibility
      # dep_lock: Dependency management lock file, generated by dep ensure and
      #           dep init
      # go_mod: Go package versioning introduced in Go 1.11^
      # go_sum: Contains the expected cryptographic checksums of the content of
      #         specific module versions, go.mod & go.sum are usually pairs
      { handle: :dep_lock, filename: 'Gopkg.lock' },
      { handle: :go_mod, filename: 'go.mod' },
      { handle: :go_sum, filename: 'go.sum' },
      # Python
      { handle: :requirements_txt, filename: 'requirements.txt' },
      { handle: :setup_cfg, filename: 'setup.cfg' },
      # Rust
      { handle: :cargo, filename: 'Cargo.toml' },
      { handle: :cargo_lock, filename: 'Cargo.lock' },
      # Mobile Scanners
      { handle: :android_app, filename: '.apk', wildcard: true },
      { handle: :ios_app, filename: '.ipa', wildcard: true },
      # Java
      { handle: :pom_xml, filename: 'pom.xml' },
      { handle: :build_gradle, filename: 'build.gradle' }
    ].freeze

    # Define file checkers.
    IMPORTANT_FILES.each do |file|
      define_method :"#{file[:handle]}_present?" do
        if file[:wildcard]
          files = Dir["#{@path_to_repo}/**/*#{file[:filename]}"]
          return false unless files.any?

          return files
        end

        File.exist?("#{@path_to_repo}/#{file[:filename]}")
      end
    end

    # Define cached file getters.
    IMPORTANT_FILES.each do |file|
      define_method file[:handle] do
        cache_handle = "@#{file[:handle]}_contents"

        if File.exist?("#{@path_to_repo}/#{file[:filename]}")
          if instance_variable_get(cache_handle).nil?
            instance_variable_set(cache_handle, File.read("#{@path_to_repo}/#{file[:filename]}"))
          end
        end

        instance_variable_get(cache_handle)
      end
    end

    def initialize(path_to_repo = nil)
      @path_to_repo = path_to_repo
    end
  end
end
