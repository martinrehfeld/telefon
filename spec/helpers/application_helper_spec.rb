require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do
  
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ApplicationHelper)
  end
  
  describe "content :head helper" do
    describe "javascript" do
      it "should add a javascript_include_tag to the :head content" do
        helper.capture {
          helper.javascript('file1', 'file2')
        }.should == helper.javascript_include_tag('file1', 'file2')
      end
    end
    
    describe "javascript with block" do
      it "should also add a javascript_tag with contents the block" do
        helper.capture {
          helper.javascript('file1', 'file2') { "return;" }
        }.should == helper.javascript_include_tag('file1', 'file2') + "\n" + helper.javascript_tag("return;")
      end
    end

    describe "stylesheet" do
      it "should add a stylesheet_link_tag to the :head content" do
        helper.capture {
          helper.stylesheet 'file1', 'file2'
        }.should == helper.stylesheet_link_tag('file1', 'file2')
      end
    end
  end

end
