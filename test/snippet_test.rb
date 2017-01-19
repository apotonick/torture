require "test_helper"

class SnippetTest < Minitest::Spec
  let (:txt) {
%{
 ignore

 #:ignore-me
 more to ignore
 #:ignore-me end

  #:op-op
    ops

    *are*
  #:op-op end
}
  }

  it do
    Torture::Snippet.for(txt, marker: "op-op").must_equal %{<pre><code>  ops

  *are*
</code></pre>
}
  end

  # not indented code
let (:notindented) { %{
#:op-op
code
  not
really indented
#:op-op end
} }
it do
    Torture::Snippet.for(notindented, marker: "op-op").must_equal %{<pre><code>code
  not
really indented
</code></pre>
}
  end


  it do
    Torture::Snippet.call(file: "test/fixtures/operation_test.rb", marker: "invocation-dep").must_equal %{<pre><code>class Create &lt; Trailblazer::Operation
  step     Model( Song, :new )
  step     :assign_current_user!
  # ..
  def assign_current_user!(options)
    options[\"model\"].created_by = options[\"current_user\"]
  end
end
</code></pre>
}
  end

  it do
    Torture::Snippet.call(file: "operation_test.rb", root: "test/fixtures", marker: "invocation-dep").must_equal %{<pre><code>class Create &lt; Trailblazer::Operation
  step     Model( Song, :new )
  step     :assign_current_user!
  # ..
  def assign_current_user!(options)
    options[\"model\"].created_by = options[\"current_user\"]
  end
end
</code></pre>
}
  end
end
