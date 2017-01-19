module Torture
  module Snippet
    def self.call(file:, root: "./", **kws)
      input = File.open(File.join(root, file))
      self.for(input, **kws)
    end

    def self.for(input, marker:, hide:nil)
      code = nil
      ignore = false

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

        code << ln and next unless code.nil?
        code = "" if ln =~ /\#:#{marker}$/ # beginning of our section.
      end

      indented = ""
      code.each_line { |ln| indented << "  "+ln }

      Kramdown::Document.new(indented).to_html
    end
  end
end
