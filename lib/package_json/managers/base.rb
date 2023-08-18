class PackageJson
  module Managers
    class Base # rubocop:disable Metrics/ClassLength
      def initialize(package_json, manager_cmd:)
        # @type [PackageJson]
        @package_json = package_json
        # @type [String]
        @manager_cmd = manager_cmd
      end

      def version
        require "open3"

        command = "#{@manager_cmd} --version"
        stdout, stderr, status = Open3.capture3(command)

        unless status.success?
          raise PackageJson::Error, "#{command} failed with exit code #{status.exitstatus}: #{stderr}"
        end

        stdout.chomp
      end

      # Installs the dependencies specified in the `package.json` file
      def install(
        frozen: false,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        raise NotImplementedError
      end

      # Provides the "native" command for installing dependencies with this package manager for embedding into scripts
      def native_install_command(
        frozen: false,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        raise NotImplementedError
      end

      # Installs the dependencies specified in the `package.json` file
      def install!(
        frozen: false,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        raise_exited_with_non_zero_code_error unless install(
          frozen: frozen,
          ignore_scripts: ignore_scripts,
          legacy_peer_deps: legacy_peer_deps,
          omit_optional_deps: omit_optional_deps
        )
      end

      # Adds the given packages
      def add(
        packages,
        type: :production,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        raise NotImplementedError
      end

      # Adds the given packages
      def add!(
        packages,
        type: :production,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        raise_exited_with_non_zero_code_error unless add(
          packages,
          type: type,
          ignore_scripts: ignore_scripts,
          legacy_peer_deps: legacy_peer_deps,
          omit_optional_deps: omit_optional_deps
        )
      end

      # Removes the given packages
      def remove(
        packages,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        raise NotImplementedError
      end

      # Removes the given packages
      def remove!(
        packages,
        ignore_scripts: false,
        legacy_peer_deps: false,
        omit_optional_deps: false
      )
        raise_exited_with_non_zero_code_error unless remove(
          packages,
          ignore_scripts: ignore_scripts,
          legacy_peer_deps: legacy_peer_deps,
          omit_optional_deps: omit_optional_deps
        )
      end

      # Runs the script assuming it is defined in the `package.json` file
      def run(
        script_name,
        args = [],
        silent: false
      )
        raise NotImplementedError
      end

      # Runs the script assuming it is defined in the `package.json` file
      def run!(
        script_name,
        args = [],
        silent: false
      )
        raise_exited_with_non_zero_code_error unless run(
          script_name,
          args,
          silent: silent
        )
      end

      # Provides the "native" command for running the script with args for embedding into shell scripts
      def native_run_command(
        script_name,
        args = [],
        silent: false
      )
        raise NotImplementedError
      end

      private

      def raise_exited_with_non_zero_code_error
        raise Error, "#{@manager_cmd} exited with non-zero code"
      end

      def build_full_cmd(cmd, args)
        [@manager_cmd, cmd, *args].join(" ")
      end

      def raw(cmd, args)
        Kernel.system(build_full_cmd(cmd, args), chdir: @package_json.path)
      end
    end
  end
end
