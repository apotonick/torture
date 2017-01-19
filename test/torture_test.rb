require "test_helper"
require "test_xml/mini_test"

class TortureTest < Minitest::Spec
  it do
    md = %{
  ~~~4,offset-2
  ~~~3
  first
  ~~~3
  second **CONCEPT**
  }

    html = %{<section class=" ">
  <div class="row">
    <div class="column medium-4 offset-2">


      </div>
    <div class="column medium-3 ">
        <p>first</p>


      </div>
    <div class="column medium-3 ">
        <p>second <strong>CONCEPT</strong></p>


      </div>
</div></section>}

puts Torture::Foundation6::Row.new.(md)

    Torture::Foundation6::Row.new.(md).must_equal html
  end
end
