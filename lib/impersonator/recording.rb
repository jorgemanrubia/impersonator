# frozen_string_literal: true

module Impersonator
  # A recording is responsible for saving interactions at record time, and replaying them at
  # replay time.
  #
  # A recording is always in one of two states.
  #
  # * {RecordMode Record mode}
  # * {ReplayMode Replay mode}
  #
  # The state objects are responsible of dealing with the recording logic, which happens in 3
  # moments:
  #
  # * {#start}
  # * {#invoke}
  # * {#finish}
  #
  # @see RecordMode
  # @see ReplayMode
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

      initialize_current_mode
    end

    # Start a recording/replay session
    def start
      logger.debug "Starting recording #{label}..."
      current_mode.start
    end

    # Handles the invocation of a given method on the impersonated object
    #
    # It will either record the interaction or replay it dependening on if there
    # is a recording available or not
    #
    # @param [Object, Double] impersonated_object
    # @param [MethodInvocation] method
    # @param [Array<Object>] args
    def invoke(impersonated_object, method, args)
      current_mode.invoke(impersonated_object, method, args)
    end

    # Finish a record/replay session.
    def finish
      logger.debug "Recording #{label} finished"
      current_mode.finish
    end

    # Return whether it is currently at replay mode
    #
    # @return [Boolean]
    def replay_mode?
      @current_mode == replay_mode
    end

    # Return whether it is currently at record mode
    #
    # @return [Boolean]
    def record_mode?
      !replay_mode?
    end

    private

    attr_reader :current_mode

    def initialize_current_mode
      @current_mode = if can_replay?
                        replay_mode
                      else
                        record_mode
                      end
    end

    def can_replay?
      !@disabled && File.exist?(recording_path)
    end

    def record_mode
      @record_mode ||= RecordMode.new(recording_path)
    end

    def replay_mode
      @replay_mode ||= ReplayMode.new(recording_path)
    end

    def recording_path
      File.join(@recordings_path, "#{label_as_file_name}.yml")
    end

    def label_as_file_name
      label.downcase.gsub(/[\(\)\s \#:]/, '-').gsub(/[\-]+/, '-').gsub(/(^-)|(-$)/, '')
    end
  end
end
