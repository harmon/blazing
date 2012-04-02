module Blazing
  class Hook

    include Blazing::Logger

    attr_accessor :target

    def initialize(target)
      @target = target

      # TODO: Wrap these into target?
      @config = target.config
      @options = target.options
      @shell = Blazing::Shell.new
    end

    def setup
      prepare_hook
      deploy_hook
    end

    def rake_command
      rake_config = @config.instance_variable_get("@rake") || {}
      rails_env = "RAILS_ENV=#{@options[:rails_env]}" if @options[:rails_env]

      if rake_config[:task]
        "#{rake_config[:env]} #{rails_env} bundle exec rake #{rake_config[:task]}"
      end
    end

    private

    def prepare_hook
      info "Generating and uploading post-receive hook for #{@target.name}"
      hook = generate_hook
      write hook
    end

    def deploy_hook
      debug "Copying hook for #{@target.name} to #{@target.location}"
      copy_hook
      set_hook_permissions
    end

     def generate_hook
      ERB.new(File.read("#{Blazing::TEMPLATE_ROOT}/hook.erb")).result(binding)
     end

     def write(hook)
      File.open(Blazing::TMP_HOOK, "wb") do |f|
        f.puts hook
      end
     end

     def set_hook_permissions
      if @target.host
        @shell.run "ssh #{@target.user}@#{@target.host} #{make_hook_executable}"
      else
        @shell.run "#{make_hook_executable}"
      end
     end

    def copy_hook
      debug "Making hook executable"
      # TODO: handle missing user?
      if @target.host
        @shell.run "scp #{Blazing::TMP_HOOK} #{@target.user}@#{@target.host}:#{@target.path}/.git/hooks/post-receive"
      else
        @shell.run "cp #{Blazing::TMP_HOOK} #{@target.path}/.git/hooks/post-receive"
      end
    end

    def make_hook_executable
      debug "Making hook executable"
      "chmod +x #{@target.path}/.git/hooks/post-receive"
    end
  end
end

