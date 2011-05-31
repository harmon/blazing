require 'spec_helper'
require 'blazing/cli/base'

describe Blazing::CLI::Base do

  before :all do
    Blazing.send(:remove_const, 'CONFIGURATION_FILE')
    Blazing::CONFIGURATION_FILE = 'spec/support/config.rb'
  end

  before :each do
    @logger = double('logger', :log => nil, :report => nil)
    @runner = double('runner', :run => nil)
    @hook = double('hook', :new => double('template', :generate => nil))
    @base =  Blazing::CLI::Base.new(@logger)
  end

  describe '#init' do
    it 'invokes all CLI::Create tasks' do
      @create_task = double('create task')
      @base.instance_variable_set('@task', @create_task)
      @create_task.should_receive(:invoke_all)
      @base.init
    end
  end

  describe '#setup' do

    before :each do
      @some_target_name = 'test_target'
      hook = double('hook', :new => double('template', :generate => nil))
      config = Blazing::Config.new
      config.target(@some_target_name, :deploy_to => 'smoeone@somewhere:/asdasdasd', :_logger => @logger, :_runner => @runner, :_hook => hook)
      @base.instance_variable_set('@config', config)
    end

    it 'says what target is being setup' do
      @logger.should_receive(:log).with(:info, "setting up target test_target")
      @base.setup(@some_target_name)
    end

    it 'runs setup on selected target' do
      @target = @base.instance_variable_get('@config').instance_variable_get('@targets').first
      @target.should_receive(:setup)
      @base.setup(@some_target_name)
    end

    it 'logs a success message if exitstatus of setup was 0' do
      @base.instance_variable_set('@exit_status', 0)
      @logger.should_receive(:log).with(:success, "successfully set up target test_target")
      @base.setup(@some_target_name)
    end

    it 'logs an error if exitstatus of setup was not 0' do
      @base.instance_variable_set('@exit_status', 1)
      @logger.should_receive(:log).with(:error, "failed setting up target test_target")
      @base.setup(@some_target_name)
    end
  end

  describe '#deploy' do

    before :each do
      @some_target_name = 'test_target'
      hook = double('hook', :new => double('template', :generate => nil))
      config = Blazing::Config.new
      config.target(@some_target_name, :deploy_to => 'smoeone@somewhere:/asdasdasd', :_logger => @logger, :_runner => @runner, :_hook => hook)
      @base.instance_variable_set('@config', config)
    end

    it 'says what target is being deployed' do
      @logger.should_receive(:log).with(:info, "deploying target test_target")
      @base.deploy(@some_target_name)
    end

    it 'runs setup on selected target' do
      @target = @base.instance_variable_get('@config').instance_variable_get('@targets').first
      @target.should_receive(:deploy)
      @base.deploy(@some_target_name)
    end

    it 'logs a success message if exitstatus of setup was 0' do
      @base.instance_variable_set('@exit_status', 0)
      @logger.should_receive(:log).with(:success, "successfully deployed target test_target")
      @base.deploy(@some_target_name)
    end

    it 'logs an error if exitstatus of setup was not 0' do
      @base.instance_variable_set('@exit_status', 1)
      @logger.should_receive(:log).with(:error, "failed deploying on target test_target")
      @base.deploy(@some_target_name)
    end
  end

  describe '#recipes' do
    it 'prints a list of available recipes' do
      @logger.should_receive(:log).exactly(2).times
      @base.recipes
    end
  end

end
