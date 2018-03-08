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

    # Adding link to Github functionality
    def self.extract_line_number_and_filename_from(file:, root: "./", **kws)
      input = File.open(File.join(root, file))
      line_number = self.extract_line_number(input, **kws)

      return {path: File.join(root, file), line: line_number}
    end

    def self.extract_line_number(input, marker:)
      line_number = nil
      input.each_with_index do |ln, index|
        # beginning of our section?
        if  beginning_of_section?(ln, marker)
          line_number = index + 2
        end
      end
      return line_number
    end

    def self.build_github_link(github_user: 'trailblazer', gem_name:, branch: 'master', path: , line_number: )
      "https://github.com/#{github_user}/#{gem_name}/blob/#{branch}/#{path}#L#{line_number}"
    end

    # @param :collapse name of the #~collapse marker that will be displayed as `# ...`.
    def self.new_extract(input, marker:, collapse:nil, unindent:false)
      code = nil     # also acts as a flag if we're within our section.
      ignore = false
      indent = 0

      input.each_line do |ln|
        # end of our section?
        break if end_of_section?(ln, marker)

        # beginning of our section?
        if  beginning_of_section?(ln, marker)
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

    def self.end_of_section?(line, marker)
      (line =~ /\#:#{marker} end/) ? true : false
    end
    def self.beginning_of_section?(line, marker)
      (line =~ /\#:#{marker}$/) ? true : false
    end



  end
end
