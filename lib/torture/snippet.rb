module Torture
  module Snippet
    def self.call(file:, root: "./", **kws)
      input = File.open(File.join(root, file))
      self.for(input, **kws)
    end


    # TODO: remove me!
    def self.for(input, **kws)
      code = extract(input, **kws)

      Kramdown::Document.new(code).to_html
      # %{<pre><code>#{code}</code></pre>\n}
    end

    def self.extract_from(file:, root:, **kws)
      input = File.open(File.join(root, file))
      self.new_extract(input, **kws)
    end

    def self.new_extract(input, marker:, hide:nil, unindent:false)
      code = nil
      ignore = false
      indent = 0

      input.each_line do |ln|
        break if ln =~ /\#:#{marker} end/

        if ln =~ /#~#{hide}$/
          ignore = true
          code << ln.sub("#~#{hide}", "# ...")
        end

        if ln =~ /#~#{hide} end/
          ignore = false
          next
        end

        next if ignore
        next if ln =~ /#~/
        next if ln =~ /#:/ && code


        code << ln and next unless code.nil?

        if ln =~ /\#:#{marker}$/ # beginning of our section.
          code   = ""
          indent = ln.match(/(^\s+)/) { |m| m[0].size } || 0
        end
      end

      raise "Couldn't find #{marker}" unless code

      code = unindent(code, indent) if unindent == true
puts
puts code

      code
    end

    # TODO: remove me!
    def self.extract(input, marker:, hide:nil, unindent:false)
      code = nil
      ignore = false
      indent = 0

      input.each_line do |ln|
        break if ln =~ /\#:#{marker} end/

        if ln =~ /#~#{hide}$/
          ignore = true
          code << Indent(Trim(ln.sub("#~#{hide}", "# ..."), indent)) # TODO: fix redundancy.
        end

        if ln =~ /#~#{hide} end/
          ignore = false
          next
        end

        next if ignore
        next if ln =~ /#~/
        next if ln =~ /#:/ && code



        code << Indent(Trim(ln, indent)) and next unless code.nil?
        if ln =~ /\#:#{marker}$/ # beginning of our section.
          code   = ""
          indent = ln.match(/(^\s+)/) { |m| m[0].size } || 0
        end
      end

      raise "Couldn't find #{marker}" unless code

      code
    end

    # TODO: remove me!
    def self.Trim(line, count, do_trim=true)
      return line unless do_trim || count
      line[count..-1] || "\n"
    end

    # TODO: remove me!
    def self.Indent(line, count=4)
      " "*count + line
    end

    # Strip {indent} characters of whitespace from each line beginning.
    def self.unindent(code, indent)
      code.gsub(/^ {#{indent}}/, "")
    end
  end
end
