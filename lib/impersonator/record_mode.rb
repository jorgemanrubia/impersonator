module Impersonator
  # The state of a {Recording recording} in record mode
  class RecordMode
    include HasLogger

    # recording file path
    attr_reader :recording_path

    # @param [String] recording_path the file path to the recording file
    def initialize(recording_path)
      @recording_path = recording_path
    end

    # Start a recording session
    def start
      logger.debug 'Recording mode'
      make_sure_recordings_dir_exists
      @method_invocations = []
    end

    # Records the method invocation
    #
    # @param [Object, Double] impersonated_object
    # @param [MethodInvocation] method
    # @param [Array<Object>] args
    def invoke(impersonated_object, method, args)
      spiable_block = method&.block_spy&.block
      impersonated_object.send(method.name, *args, &spiable_block).tap do |return_value|
        record(method, return_value)
      end
    end

    # Finishes the record session
    def finish
      File.open(recording_path, 'w') do |file|
        YAML.dump(@method_invocations, file)
      end
    end

    private

    # Record a {MethodInvocation method invocation} with a given return value
    # @param [Method] method
    # @param [Object] return_value
    def record(method, return_value)
      method_invocation = MethodInvocation.new(method_instance: method, return_value: return_value)

      @method_invocations << method_invocation
    end

    def make_sure_recordings_dir_exists
      dirname = File.dirname(recording_path)
      FileUtils.mkdir_p(dirname) unless File.directory?(dirname)
    end
  end
end
