module Impersonator
  # The state of a {Recording recording} in replay mode
  class ReplayMode
    include HasLogger

    # recording file path
    attr_reader :recording_path

    # @param [String] recording_path the file path to the recording file
    def initialize(recording_path)
      @recording_path = recording_path
    end

    # Start a replay session
    def start
      logger.debug 'Replay mode'
      @replay_mode = true
      @method_invocations = YAML.load_file(recording_path)
    end

    # Replays the method invocation
    #
    # @param [Object, Double] impersonated_object not used in replay mode
    # @param [MethodInvocation] method
    # @param [Array<Object>] args not used in replay mode
    def invoke(_impersonated_object, method, _args)
      method_invocation = @method_invocations.shift
      unless method_invocation
        raise Impersonator::Errors::MethodInvocationError, 'Unexpected method invocation received:'\
              "#{method}"
      end

      validate_method_signature!(method, method_invocation.method_instance)
      replay_block(method_invocation, method)

      method_invocation.return_value
    end

    # Finishes the record session
    def finish
      unless @method_invocations.empty?
        raise Impersonator::Errors::MethodInvocationError,
              "Expecting #{@method_invocations.length} method invocations"\
              " that didn't happen: #{@method_invocations.inspect}"
      end
    end

    private

    def replay_block(recorded_method_invocation, method_to_replay)
      block_spy = recorded_method_invocation.method_instance.block_spy
      block_spy&.block_invocations&.each do |block_invocation|
        method_to_replay.block.call(*block_invocation.arguments)
      end
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
