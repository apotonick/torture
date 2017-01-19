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
end
