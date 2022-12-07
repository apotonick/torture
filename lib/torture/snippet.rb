module Torture
  module Snippet
    def self.extract_from(file:, **kws)
      input = File.open(file)
      self.extract(input, **kws)
    end

    # @param :collapse name of the #~collapse marker that will be displayed as `# ...`.
    def self.extract(input, marker:, collapse:nil, unindent:false, sub: nil)
      code = nil     # also acts as a flag if we're within our section.
      ignore = false
      indent = 0

      input.each_line do |ln|
        # end of our section?
        break if ln =~ /\#:#{marker} end/

        # beginning of our section?
        if ln =~ /\#:#{marker}$/
          code   = ""
          indent = ln.match(/(^\s+)/) { |m| m[0].size } || 0
        end

        next if code.nil? # not in our section.

        if ln =~ /#~#{collapse}$/
          ignore = true
          code << ln.sub("#~#{collapse}", "# ...")
        end

        if ln =~ /#~#{collapse} end/
          ignore = false
          next
        end

        next if ignore
        next if ln =~ /#~/
        next if ln =~ /#:/
        code << ln and next
      end

      raise "Couldn't find #{marker}" unless code

      code = unindent(code, indent) if unindent == true
      code = sub(code, sub) if sub

      code
    end

    # Strip {indent} characters of whitespace from each line beginning.
    def self.unindent(code, indent)
      code.gsub(/^ {#{indent}}/, "")
    end

    def self.sub(code, sub)
      code.sub(sub, "")
    end
  end
end
