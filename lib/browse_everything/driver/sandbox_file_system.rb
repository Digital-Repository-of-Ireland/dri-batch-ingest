module BrowseEverything::Driver
  class SandboxFileSystem < BrowseEverything::Driver::FileSystem

    def contents(path = '')
      real_path = File.join(home, path)
      @entries = if File.directory?(real_path)
                   make_directory_entry real_path
                 else
                   [details(real_path)]
                 end

      @sorter.call(@entries)
    end

    def home
      return config[:home] unless config.key?(:sandbox_template)

      sandbox_dir = config[:sandbox_template].gsub(/({\S+})/) { |m| config[m.delete('{}').to_sym] }
      File.join(config[:home], sandbox_dir)
    end

  end
end
