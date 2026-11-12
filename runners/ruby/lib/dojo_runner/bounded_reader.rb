module DojoRunner
  # Drains a pipe on a background thread, keeping only the first `limit`
  # bytes. It keeps reading (and discarding) so a chatty child never blocks
  # on a full pipe.
  class BoundedReader
    CHUNK = 16 * 1024

    # @param io [IO] read end of a pipe
    # @param limit [Integer] bytes to keep
    def initialize(io, limit)
      @io = io
      @limit = limit
      @kept = +""
      @dropped = 0
    end

    # @return [BoundedReader] self, with the reader thread running
    def start
      @thread = Thread.new { drain }
      self
    end

    # Waits briefly for the pipe to close, then returns what was kept.
    #
    # @param wait_s [Numeric] how long to wait for stragglers holding the pipe
    # @return [String] UTF-8 text, with a marker if output was truncated
    def value(wait_s: 2)
      @thread.join(wait_s) || @thread.kill
      @io.close unless @io.closed?
      text = @kept.force_encoding(Encoding::UTF_8).scrub
      @dropped.zero? ? text : "#{text}\n...[output truncated: #{@dropped} more bytes]"
    end

    private

    def drain
      while (chunk = @io.readpartial(CHUNK))
        keep(chunk)
      end
    rescue EOFError, IOError
      nil
    end

    def keep(chunk)
      room = @limit - @kept.bytesize
      @kept << chunk.byteslice(0, room) if room.positive?
      @dropped += [ chunk.bytesize - [ room, 0 ].max, 0 ].max
    end
  end
end
