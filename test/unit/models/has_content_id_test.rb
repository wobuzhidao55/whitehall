require 'test_helper'

class HasContentIdTest < ActiveSupport::TestCase
  class TestObject
    attr_accessor :content_id
    def self.before_validation(*args)
    end
    def self.validates(*args)
    end
  end

  test "it sets up generate content id" do
    t_obj = TestObject.new
    TestObject.expects(:before_validation).with(:generate_content_id, { on: :create })
    class << t_obj
      include HasContentId
    end
  end

  test "it uses a SecureRandom.uuid for the content_id" do
    expected = SecureRandom.uuid
    SecureRandom.stubs(:uuid).returns(expected)
    t_obj = TestObject.new
    class << t_obj
      include HasContentId
    end
    t_obj.send(:generate_content_id)
    assert_equal expected, t_obj.content_id
  end

  test "it sets up validation" do
    t_obj = TestObject.new
    TestObject.expects(:validates).with(:content_id, { presence: true })
    class << t_obj
      include HasContentId
    end
  end
end
