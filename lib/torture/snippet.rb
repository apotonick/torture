module Torture
  module Snippet
    def call(input, hide=nil)
      file, section = input.split(":")

      file = "../trailblazer/test/docs/#{file}" unless file.match("/")

      code = nil
      ignore = false

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
