module Torture
  module Snippet
    def self.call(file:, root: "./", **kws)

      input = File.open(File.join(root, file))
      self.for(input, **kws)
    end

    def self.for(input, marker:, hide:nil)
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

      Kramdown::Document.new(code).to_html
      # %{<pre><code>#{code}</code></pre>\n}
    end

    def self.Trim(line, count, do_trim=true)
      return line unless do_trim || count
      line[count..-1] || "\n"
    end

    def self.Indent(line, count=4)
      " "*count + line
    end
  end
end
