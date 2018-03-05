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

  it "allows the same-named #~hide block in different sections" do
    txt = %{
  #:update
  update{
    #~skip
      update skip
    #~skip end
  } #update
  #:update end

  #:create
  create{
    #~skip
      create skip
    #~skip end
  } #create
  #:create end
}
    assert_snippet Torture::Snippet.new_extract(txt, marker: "update", collapse: :skip), %{
%%update{
%%%%#%...
%%}%#update
}
    assert_snippet Torture::Snippet.new_extract(txt, marker: "create", collapse: :skip), %{
%%create{
%%%%#%...
%%}%#create
}
  end

  it "allows passing :hide without actual #~hide block" do
    txt = %{
a
  #:update
  update{
      update content
  } #update
  #:update end

b
}
    assert_snippet Torture::Snippet.new_extract(txt, marker: "update", collapse: :skip), %{
%%update{
%%%%%%update%content
%%}%#update
}
  end


  it "returns the line number and link is fine" do
    path_and_line = Torture::Snippet.extract_line_number_and_filename_from(file: "operation_test.rb", root: "test/fixtures",  marker: "invocation-dep")
    assert_equal path_and_line, {path: "test/fixtures/operation_test.rb", line: 10}

    link = "https://github.com/apotonick/torture/blob/master/test/fixtures/operation_test.rb#L10"
    assert_equal Torture::Snippet.build_github_link(github_user: 'apotonick', gem_name: 'torture', path: path_and_line[:path], line_number: path_and_line[:line] ), link
  end




  def assert_snippet(actual, expected)
    actual.gsub(" ","%").must_equal(expected.sub(/^\n/, ""))
  end
end

#TODO: test when marker non-existent
