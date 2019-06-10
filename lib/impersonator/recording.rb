module Impersonator
  class Recording
    include HasLogger

    attr_reader :label

    def initialize(label)
      @label = label
    end

    def start
      logger.debug "Starting recording #{label}..."
      if File.exist?(file_path)
        start_in_replay_mode
      else
        start_in_record_mode
      end
    end

    def record(method, return_value)
      method_invocaation = MethodInvocation.new(method: method, return_value: return_value)
      @method_invocations << method_invocaation
    end

    def replay(method)
      # todo: pending check signatures, etc...
      method_invocation = @method_invocations.shift
      method_invocation.return_value
    end

    def finish
      logger.debug "Recording #{label} finished"
      if record_mode?
        finish_in_record_mode
      else

      end
    end

    def replay_mode?
      @replay_mode
    end

    def record_mode?
      !replay_mode?
    end

    private

    def start_in_replay_mode
      logger.debug "Replay mode"
      @replay_mode = true
      @method_invocations = YAML.load_file(file_path)
    end

    def start_in_record_mode
      logger.debug "Recording mode"
      @replay_mode = false
      make_sure_fixtures_dir_exists
      @method_invocations = []
    end

    def finish_in_record_mode
      File.open(file_path, 'w') do |file|
        YAML.dump(@method_invocations, file)
      end
    end

    def file_path
      "spec/recordings/#{label}.yml"
    end

    def make_sure_fixtures_dir_exists
      dirname = File.dirname(file_path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    end
  end
end
