require "net/http"

module Net
  class PTTH
    class TestServer
      # Public: Initialize the PTTH test server
      #
      #   port: the port in which the server will listen
      #
      def initialize(configuration = {})
        port = configuration.fetch(:port, 23045)
        response = Net::HTTP::Post.new("/reverse")
        response.body = "reversed"

        @response = configuration.fetch(:response, response)
        @server = TCPServer.new(port)
      end

      # Public: Starts the test server
      #
      def start
        loop do
          client = @server.accept

          switch_protocols = "HTTP/1.1 101 Switching Protocols#{CRLF}" \
                             "Date: Mon, 14 Jan 2013 11:54:24 GMT#{CRLF}" \
                             "Upgrade: PTTH/1.0#{CRLF}" \
                             "Connection: Upgrade#{CRLF}" \
                             "#{CRLF}"

          post_response  = "#{@response.method} #{@response.path} HTTP/1.1#{CRLF}"
          post_response += "Content-Length: #{@response.body.length}#{CRLF}" if @response.body
          post_response += "Accept: */*#{CRLF}"
          post_response += "#{CRLF}"
          post_response += @response.body if @response.body

          client.puts switch_protocols
          sleep 0.5
          client.puts post_response
          client.read unless client.eof?
        end
      end

      # Public: Stops the current server
      #
      def close
        @server.close
      end
    end
  end
end
