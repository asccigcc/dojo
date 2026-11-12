module DojoRunner
  # A validated /run payload. Everything the sandbox needs comes from here, so
  # nothing unchecked from the request reaches the filesystem or the process.
  class RunRequest
    MODES = %w[minitest expression].freeze
    ALLOWED_ENV = %w[PART].freeze
    PATH_FORMAT = %r{\A[A-Za-z0-9_-]+(/[A-Za-z0-9_-]+)*\.rb\z}
    EXPRESSION_FILES = %w[answer.rb expected.rb].freeze
    MAX_FILES = 16
    MAX_FILE_BYTES = 200_000
    TIMEOUT_RANGE = (1..10)
    DEFAULT_TIMEOUT = 5

    attr_reader :mode, :files, :env, :timeout_s, :entry

    # @param body [String] raw JSON request body
    # @return [RunRequest]
    # @raise [InvalidRequest]
    def self.parse(body)
      payload = JSON.parse(body)
      raise InvalidRequest, "payload must be an object" unless payload.is_a?(Hash)

      new(payload)
    rescue JSON::ParserError
      raise InvalidRequest, "body is not valid JSON"
    end

    # @param payload [Hash] decoded JSON
    # @raise [InvalidRequest]
    def initialize(payload)
      @mode = check_mode(payload["mode"])
      @files = check_files(payload["files"])
      @env = check_env(payload["env"] || {})
      @timeout_s = check_timeout(payload["timeout_s"])
      @entry = check_entry(payload["entry"])
    end

    private

    def check_mode(mode)
      MODES.include?(mode) ? mode : invalid("mode must be one of #{MODES.join(', ')}")
    end

    def check_files(files)
      invalid("files must be an object") unless files.is_a?(Hash) && files.size.between?(1, MAX_FILES)
      files.each { |path, content| check_file(path, content) }
      files
    end

    def check_file(path, content)
      invalid("bad file path: #{path.inspect}") unless path.is_a?(String) && path.match?(PATH_FORMAT)
      invalid("file #{path} must be a string") unless content.is_a?(String)
      invalid("file #{path} is too large") if content.bytesize > MAX_FILE_BYTES
    end

    def check_env(env)
      invalid("env must be an object") unless env.is_a?(Hash)
      env.each { |key, value| check_env_pair(key, value) }
      env.transform_values(&:to_s)
    end

    def check_env_pair(key, value)
      invalid("env #{key} is not allowed") unless ALLOWED_ENV.include?(key)
      invalid("env #{key} must be a short scalar") unless value.to_s.match?(/\A[\w.-]{0,32}\z/)
    end

    def check_timeout(value)
      return DEFAULT_TIMEOUT if value.nil?

      Integer(value, exception: false)&.clamp(TIMEOUT_RANGE) || invalid("timeout_s must be an integer")
    end

    def check_entry(entry)
      return check_expression_files if mode == "expression"
      return entry if files.key?(entry)

      invalid("entry must name one of the files")
    end

    def check_expression_files
      missing = EXPRESSION_FILES - files.keys
      missing.empty? ? nil : invalid("expression mode needs #{missing.join(', ')}")
    end

    def invalid(message) = raise(InvalidRequest, message)
  end
end
