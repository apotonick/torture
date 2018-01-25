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
    #..
  #:op-op end
}
  }

  it do
    Torture::Snippet.for(txt, marker: "op-op").must_equal %{<pre><code>  ops

  *are*
  #..
</code></pre>
}
  end

  # with hide
  let (:with_hide) {
%{
 ignore
  #:op-op
    Bla
    #~bla
    ops
    #~bla end

    *are*
  #:op-op end
}
  }

  it do
    Torture::Snippet.for(with_hide, marker: "op-op", hide: "bla").must_equal %{<pre><code>  Bla
  # ...

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

  #:marker in :marker
  let (:marker_in_marker) { %{#:marker
  bla
  #:inside
  blub
  #:inside end
  more bla
  #:marker end
   }
  }

  it do
    Torture::Snippet.for(marker_in_marker, marker: "marker").must_equal %{<pre><code>  bla
  blub
  more bla
</code></pre>
}
  end

  # missing :marker

  it { assert_raises(RuntimeError) { Torture::Snippet.for("\nbla\n", marker: "marker") }  }

  # ::call
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


  describe "Snippet.extract" do
    it "returns the extracted code, only" do

      assert_snippet Torture::Snippet.extract(txt, marker: "op-op"), %{
%%%%%%ops
%%%%
%%%%%%*are*
%%%%%%#..
}
    end

    it "accepts unindent: true" do
      txt = %{
bla
   #:three
   three spaces in
    four
    4
      five
   end
   #:three end
more
}

      assert_snippet Torture::Snippet.new_extract(txt, marker: "three", unindent: true), %{
three%spaces%in
%four
%4
%%%five
end
}
    end
  end

  def assert_snippet(actual, expected)
    actual.gsub(" ","%").must_equal(expected.sub(/^\n/, ""))
  end
end

#TODO: test when marker non-existent
