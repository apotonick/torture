module Torture
  module Snippet
    def self.extract_from(file:, **kws)
      input = File.open(file)
      self.extract(input, **kws)
    end

    # @param :collapse name of the #~collapse marker that will be displayed as `# ...`.
    def self.extract(input, marker:, collapse:nil, unindent:false, sub: nil, zoom: nil)
      input_lines = input.each_line.to_a

      content_lines, first_line = extract_marker_section(input_lines, marker: marker)
      raise "Couldn't find #{marker}" unless first_line

      indent = first_line.match(/(^\s+)/) { |m| m[0].size } || 0 # FIXME: what if there's no first line?

      if zoom
        content_lines = zoom(content_lines, zoom: zoom)
      end

      if collapse
        count = content_lines.find_all { |ln| ln =~ /\#~#{collapse}$/ }.size # FIXME: hm, this is private.

        count.times do
          content_lines = collapse(content_lines, collapse: collapse)
        end
      end

      # remove foreign delimiters
      content_lines = content_lines.reject { |ln| ln =~ /#~/ }
      content_lines = content_lines.reject { |ln| ln =~ /#:/ }

      code = content_lines.join("")

      code = unindent(code, indent) if unindent == true
      code = sub(code, sub) if sub

      code
    end

    def self.detect_marker_section(input, delimiter:)
      start_i, stop_i = nil, nil

      input.each.with_index do |ln, i|
        # end of our section?
        if ln =~ /\##{delimiter} end/
          stop_i = i
          break
        end

        # beginning of our section?
        if ln =~ /\##{delimiter}$/
          start_i = i
        end
      end

      [start_i, stop_i]
    end

    def self.extract_marker_section(input, marker:, delimiter: ":#{marker}")
      start_i, stop_i = detect_marker_section(input, delimiter: delimiter)
      return if start_i.nil?

      marker_section = input[start_i + 1..stop_i - 1]

      return marker_section, input[start_i]
    end

    def self.marker_to_dotdotdot(line, delimiter:)
      line.sub("##{delimiter}", "# ...")
    end

    def self.zoom(input, zoom:, zoom_frame: [0..0, -1..-1])
      delimiter = "~#{zoom}"
      zoomed_section, first_line = extract_marker_section(input, marker: nil, delimiter: delimiter)

      before_range, after_range = zoom_frame # DISCUSS: do we need that?

      content = []
      content += input[before_range]
      content << dotdotdot = marker_to_dotdotdot(first_line, delimiter: delimiter)
      content += zoomed_section
      content << dotdotdot
      content += input[after_range]

      content
    end

    def self.collapse(input, collapse:)
      delimiter = "~#{collapse}"

      start_i, stop_i = detect_marker_section(input, delimiter: delimiter)


      content = if start_i == 0
          [] # if the #~skip start is index == 0, don't collect anything "before" (because there isn't anything).
          # TODO: is there a Ruby idiom for this?
        else
          input[0..start_i - 1]
        end

      content << marker_to_dotdotdot(input[start_i], delimiter: delimiter)
      content += input[stop_i + 1..-1]
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
