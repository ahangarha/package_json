require "fileutils"

def write_yarn_berry_lock
  File.write(
    "yarn.lock",
    <<~YAML
      # This file is generated by running "yarn install" inside your project.
      # Manual changes might be lost - proceed with caution!

      __metadata:
        version: 6

      "root-workspace-0b6124@workspace:.":
        version: 0.0.0-use.local
        resolution: "root-workspace-0b6124@workspace:."
        languageName: unknown
        linkType: soft
    YAML
  )
end

def setup_yarn_berry_project_template
  @yarn_berry_project_template = Dir.mktmpdir("package_json-")

  Dir.chdir(@yarn_berry_project_template) do
    args = {}
    # :nocov:
    # make things quieter by redirecting output to /dev/null
    unless ENV.fetch("PACKAGE_JSON_DEBUG", "false").downcase == "true"
      args[1] = File::NULL
      args[2] = File::NULL
    end
    # :nocov:

    Kernel.system("npx", "-y", "yarn@1", "init", "-2", args)

    # yarn berry generally always requires the lockfile to exist
    # and be up to date when doing anything, so we just include
    # it in the template directory to ensure no false results
    write_yarn_berry_lock
  end
end

def cleanup_yarn_berry_project_template
  FileUtils.rm_r(@yarn_berry_project_template)
end

def within_temp_yarn_berry_project(within_example: false)
  if @yarn_berry_project_template.nil?
    # :nocov:
    raise "yarn berry template project missing" unless within_example

    # :nocov:

    setup_yarn_berry_project_template
  end

  within_temp_directory do
    FileUtils.cp_r("#{@yarn_berry_project_template}/.", Dir.pwd)
    yield
  end
ensure
  # :nocov:
  # Ruby <3.0 coverage doesn't seem to handle this section correctly
  cleanup_yarn_berry_project_template if within_example
  # :nocov:
end