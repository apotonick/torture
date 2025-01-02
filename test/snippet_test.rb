require "test_helper"

class SnippetExtractTest < Minitest::Spec
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

  it "returns extracted code with its original indent" do
    assert_snippet Torture::Snippet.extract(txt, marker: "op-op"), %{
%%%%ops

%%%%*are*
%%%%#..
}
  end

  it "not indented code" do
    txt = %{
#:op-op
code
  not
really indented
#:op-op end
}

    assert_snippet Torture::Snippet.extract(txt, marker: "op-op"), %{
code
%%not
really%indented
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

    assert_snippet Torture::Snippet.extract(txt, marker: "three", unindent: true), %{
three%spaces%in
%four
%4
%%%five

end
}
  end

  it ":collapse substitutes a section with #..." do
    txt = %{
   ignore
    #:op-op
      Bla
      #~bla
      ops
      #~bla end

      *are*
    #:op-op end
  }
    assert_snippet Torture::Snippet.extract(txt, marker: "op-op", collapse: "bla"), %{
%%%%%%Bla
%%%%%%#%...

%%%%%%*are*
}
  end

  it ":collapse can hide several blocks with the same name in one marker section" do
    txt = %{
   ignore
    #:op-op
      Bla
      #~bla
      ops
      #~bla end
      blubb
      #~bla
      more bla
      #~bla end
      *are*
    #:op-op end
  }
    assert_snippet Torture::Snippet.extract(txt, marker: "op-op", collapse: "bla"), %{
%%%%%%Bla
%%%%%%#%...
%%%%%%blubb
%%%%%%#%...
%%%%%%*are*
}
  end

  it "allows the same-named #~collapse block in different sections" do
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
    assert_snippet Torture::Snippet.extract(txt, marker: "update", collapse: :skip), %{
%%update{
%%%%#%...
%%}%#update
}
    assert_snippet Torture::Snippet.extract(txt, marker: "create", collapse: :skip), %{
%%create{
%%%%#%...
%%}%#create
}
  end

  it "allows passing :collapse without actual #~collapse block" do
    txt = %{
a
  #:update
  update{
      update content
  } #update
  #:update end

b
}
    assert_snippet Torture::Snippet.extract(txt, marker: "update", collapse: :skip), %{
%%update{
%%%%%%update%content
%%}%#update
}
  end

  it "collapsed block can sit right after the actual marker" do
    txt = %{
   ignore
    #:op-op
      #~skip
      Bla
      #~skip end
      ops
    #:op-op end
  }
    assert_snippet Torture::Snippet.extract(txt, marker: "op-op", collapse: "skip"), %{
%%%%%%#%...
%%%%%%ops
}
  end

  it "zoom: opposite of collapse" do
    txt = %(
Header
#:controller
class MyController
  endpoint Create

  bla
  blubb
  #~directive
  this
  is important
  #~directive end

  more chatter

  and bantering
end
#:controller end
and crap
)
# TODO: zoom_lines: [0, 1, -1]
    assert_snippet Torture::Snippet.extract(txt, marker: "controller", zoom: "directive"), %{
class%MyController
%%#%...
%%this
%%is%important
%%#%...
end
}
  end

  it ":marker in :marker" do
    txt = %{#:marker
  bla
  #:inside
  blub
  #:inside end
  more bla
  #:marker end
}

  assert_snippet Torture::Snippet.extract(txt, marker: "marker"), %{
%%bla
%%blub
%%more%bla
}
  end

  # missing :marker
  it { assert_raises(RuntimeError) { Torture::Snippet.extract("\nbla\n", marker: "marker") }  }

  it "{:sub} option allows removing a substring" do
      txt = %{yo
  #:update
  Operation.call(params: {}, seq: [])
  #:update end
}
    assert_snippet Torture::Snippet.extract(txt, marker: "update", sub: ", seq: []"), %{
%%Operation.call(params:%{})
}
  end

  def assert_snippet(actual, expected)
    actual.gsub(" ","%").must_equal(expected.sub(/^\n/, ""))
  end
end


class SnippetExtractFromTest < Minitest::Spec
  it do
    Torture::Snippet.extract_from(file: "test/fixtures/operation_test.rb", marker: "invocation-dep", unindent: true).must_equal %{class Create < Trailblazer::Operation
  step     Model( Song, :new )
  step     :assign_current_user!
  # ..
  def assign_current_user!(options)
    options[\"model\"].created_by = options[\"current_user\"]
  end
end
}
  end
end
