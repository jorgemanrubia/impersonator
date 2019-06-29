# frozen_string_literal: true

module Impersonator
  # A recording is responsible for saving interactions at record time, and replaying them at
  # replay time.
  class Recording
    include HasLogger

    attr_reader :label

    # @param [String] label
    # @param [Boolean] disabled `true` for always working in *record* mode. `false` by default
    # @param [String] the path to save recordings to
    def initialize(label, disabled: false, recordings_path:)
      @label = label
      @recordings_path = recordings_path
      @disabled = disabled
    end

    # Start a recording/replay session
    def start
      logger.debug "Starting recording #{label}..."
      if can_replay?
        start_in_replay_mode
      else
        start_in_record_mode
      end
    end

    # Record a {MethodInvocation method invocation} with a given return value
    # @param [Method] method
    # @param [Object] return_value
    def record(method, return_value)
      method_invocation = MethodInvocation.new(method_instance: method, return_value: return_value)

      @method_invocations << method_invocation
    end

    # Replay a method invocation
    # @param [Method] method
    def replay(method)
      method_invocation = @method_invocations.shift
      unless method_invocation
        raise Impersonator::Errors::MethodInvocationError, 'Unexpected method invocation received:'\
              "#{method}"
      end

      validate_method_signature!(method, method_invocation.method_instance)
      replay_block(method_invocation, method)

      method_invocation.return_value
    end

    # Finish a record/replay session.
    def finish
      logger.debug "Recording #{label} finished"
      if record_mode?
        finish_in_record_mode
      else
        finish_in_replay_mode
      end
    end

    # Return whether it is currently at replay mode
    #
    # @return [Boolean]
    def replay_mode?
      @replay_mode
    end

    # Return whether it is currently at record mode
    #
    # @return [Boolean]
    def record_mode?
      !replay_mode?
    end

    private

    def can_replay?
      !@disabled && File.exist?(file_path)
    end

    def replay_block(recorded_method_invocation, method_to_replay)
      block_spy = recorded_method_invocation.method_instance.block_spy
      block_spy&.block_invocations&.each do |block_invocation|
        method_to_replay.block.call(*block_invocation.arguments)
      end
    end

    def start_in_replay_mode
      logger.debug 'Replay mode'
      @replay_mode = true
      @method_invocations = YAML.load_file(file_path)
    end

    def start_in_record_mode
      logger.debug 'Recording mode'
      @replay_mode = false
      make_sure_recordings_dir_exists
      @method_invocations = []
    end

    def finish_in_record_mode
      File.open(file_path, 'w') do |file|
        YAML.dump(@method_invocations, file)
      end
    end

    def finish_in_replay_mode
      unless @method_invocations.empty?
        raise Impersonator::Errors::MethodInvocationError,
              "Expecting #{@method_invocations.length} method invocations"\
              " that didn't happen: #{@method_invocations.inspect}"
      end
    end

    def file_path
      File.join(@recordings_path, "#{label_as_file_name}.yml")
    end

    def label_as_file_name
      label.downcase.gsub(/[\(\)\s \#:]/, '-').gsub(/[\-]+/, '-').gsub(/(^-)|(-$)/, '')
    end

    def make_sure_recordings_dir_exists
      dirname = File.dirname(file_path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    end

    def validate_method_signature!(expected_method, actual_method)
      unless actual_method == expected_method
        raise Impersonator::Errors::MethodInvocationError, <<~ERROR
          Expecting:
            #{expected_method}
          But received:
            #{actual_method}
        ERROR
      end
    end
  end
end
