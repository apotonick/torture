# require "kramdown"

module Torture
  module Foundation6
    class Row
      def call(markdown, section_class:nil)
        html =
%{<section class=" #{section_class}">
  <div class="row">
}

        cols = markdown.split("~~~")[1..-1]

        cols.each do |col|
          config, content = col.split("\n", 2)

          width, classes = config.split(",", 2)

          html <<
%{    <div class="column medium-#{width} #{classes}">
        #{Kramdown::Document.new(content).to_html}
      </div>
}
        end

        html << %{</div></section>}
        html
      end
    end # Row
  end
end
