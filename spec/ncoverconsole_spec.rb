require File.join(File.dirname(__FILE__), 'support', 'spec_helper')
require 'albacore/ncoverconsole'
require 'albacore/nunittestrunner'
require 'albacore/mspectestrunner'
require 'ncoverconsoletestdata'

describe NCoverConsole, "when specifying assemblies to cover" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    File.delete(@testdata.xml_coverage_output) if File.exist?(@testdata.xml_coverage_output)
    
    @ncc = NCoverConsole.new()
    
    @ncc.extend(SystemPatch)
    @ncc.log_level = :verbose
    @ncc.path_to_command = @testdata.ncoverpath
    @ncc.output :xml => @testdata.xml_coverage_output
    @ncc.working_directory = @testdata.working_directory
    @ncc.cover_assemblies "TestSolution"
    
    nunit = NUnitTestRunner.new(@testdata.nunitpath)
    nunit.assemblies @testdata.test_assembly
    nunit.options '/noshadow'
    
    @ncc.testrunner = nunit
    @ncc.run
  end

  it "should provide coverage for the specified assemblies" do
    @ncc.system_command.should include("//assemblies \"TestSolution\"")
  end
end

describe NCoverConsole, "when specifying assemblies to ignore" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    File.delete(@testdata.xml_coverage_output) if File.exist?(@testdata.xml_coverage_output)
    
    @ncc = NCoverConsole.new()
    
    @ncc.extend(SystemPatch)
    @ncc.log_level = :verbose
    @ncc.path_to_command = @testdata.ncoverpath
    @ncc.output :xml => @testdata.xml_coverage_output
    @ncc.working_directory = @testdata.working_directory
    @ncc.ignore_assemblies "TestSolution.*"
    
    nunit = NUnitTestRunner.new(@testdata.nunitpath)
    nunit.assemblies @testdata.test_assembly
    nunit.options '/noshadow'
    
    @ncc.testrunner = nunit
    @ncc.run
  end

  it "should provide coverage for the specified assemblies" do
    @ncc.system_command.should include("//exclude-assemblies \"TestSolution.*\"")
  end
end

describe NCoverConsole, "when running with the defaults" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    @ncc = NCoverConsole.new
    
    @ncc.extend(SystemPatch)
    @ncc.path_to_command = @testdata.ncoverpath
    @ncc.testrunner = NUnitTestRunner.new
    
    @ncc.run
  end
  
  it "should include the register flag in the command" do
    @ncc.system_command.should include "//reg"
  end
end

describe NCoverConsole, "when opting out of registering the ncover dll" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    @ncc = NCoverConsole.new
    
    @ncc.extend(SystemPatch)
    @ncc.path_to_command = @testdata.ncoverpath
    @ncc.no_registration
    @ncc.testrunner = NUnitTestRunner.new
    
    @ncc.run
  end
  
  it "should not include the register flag in the command" do
    @ncc.system_command.should_not include "//reg"
  end
end

describe NCoverConsole, "when specifying the types of coverage to analyze" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    File.delete(@testdata.xml_coverage_output) if File.exist?(@testdata.xml_coverage_output)
    
    @ncc = NCoverConsole.new()
    
    @ncc.extend(SystemPatch)
    @ncc.log_level = :verbose
    @ncc.path_to_command = @testdata.ncoverpath
    @ncc.output :xml => @testdata.xml_coverage_output
    @ncc.working_directory = @testdata.working_directory
    @ncc.coverage :Symbol, :Branch, :MethodVisits, :CyclomaticComplexity
    
    nunit = NUnitTestRunner.new(@testdata.nunitpath)
    nunit.assemblies @testdata.test_assembly
    nunit.options '/noshadow'
    
    @ncc.testrunner = nunit
    @ncc.run
  end
    
  it "should only run coverage for those metrics" do
    @ncc.system_command.should include("//coverage-type \"Symbol, Branch, MethodVisits, CyclomaticComplexity\"")
  end
end

describe NCoverConsole, "when analyzing a test suite with failing tests" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    File.delete(@testdata.xml_coverage_output) if File.exist?(@testdata.xml_coverage_output)
    
    ncc = NCoverConsole.new()
    strio = StringIO.new
    ncc.log_device = strio
    
    ncc.extend(SystemPatch)
    ncc.log_level = :verbose
    ncc.path_to_command = @testdata.ncoverpath
    ncc.output :xml => @testdata.xml_coverage_output
    ncc.working_directory = @testdata.working_directory
    
    nunit = NUnitTestRunner.new(@testdata.nunitpath)
    nunit.assemblies @testdata.failing_test_assembly
    nunit.options '/noshadow'
    
    ncc.testrunner = nunit
    
    ncc.run
    @failed = ncc.failed
    @log_data = strio.string
  end
  
  it "should return a failure code" do
    @failed.should == true
  end
  
  it "should log a failure message" do
    @log_data.should include("Code Coverage Analysis Failed. See Build Log For Detail.")
  end
end

describe NCoverConsole, "when running without a testrunner" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    ncc = NCoverConsole.new()
    strio = StringIO.new
    ncc.log_device = strio
    
    @result = ncc.run
    @log_data = strio.string
  end

  it "should log a message saying the test runner is required" do
    @log_data.should include("testrunner cannot be nil.")
  end
  
  it "should return a failure code" do
    @result.should == false
  end
end

describe NCoverConsole, "when producing an xml coverage report with nunit" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    File.delete(@testdata.xml_coverage_output) if File.exist?(@testdata.xml_coverage_output)
    
    @ncc = NCoverConsole.new()
    
    @ncc.extend(SystemPatch)
    @ncc.log_level = :verbose
    @ncc.path_to_command = @testdata.ncoverpath
    @ncc.output :xml => @testdata.xml_coverage_output
    @ncc.working_directory = @testdata.working_directory
    
    nunit = NUnitTestRunner.new(@testdata.nunitpath)
    nunit.assemblies @testdata.test_assembly
    nunit.options '/noshadow'
    
    @ncc.testrunner = nunit
    @ncc.run
  end
  
  it "should execute ncover.console from the specified path" do
    @ncc.system_command.should include(@testdata.ncoverpath)
  end
  
  it "should execute with the specified working directory" do
    @ncc.system_command.should include(@testdata.working_directory)
  end
  
  it "should execute the test runner from the specified path" do
    @ncc.system_command.should include(@testdata.nunitpath)
  end
  
  it "should pass the specified arguments to the test runner" do
    @ncc.system_command.should include("TestSolution.Tests.dll /noshadow")
  end
    
  it "should write the coverage data to the specified file" do
    File.exist?(@testdata.xml_coverage_output).should == true
  end
end

describe NCoverConsole, "when specifying an html report and an xml coverage report with nunit" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    File.delete(@testdata.xml_coverage_output) if File.exist?(@testdata.xml_coverage_output)
    File.delete(@testdata.html_coverage_output) if File.exist?(@testdata.html_coverage_output)
    
    ncc = NCoverConsole.new()
    
    ncc.extend(SystemPatch)
    ncc.log_level = :verbose
    ncc.path_to_command = @testdata.ncoverpath
    ncc.output :xml => @testdata.xml_coverage_output, :html => @testdata.html_coverage_output
    ncc.working_directory = @testdata.working_directory
    
    nunit = NUnitTestRunner.new(@testdata.nunitpath)
    nunit.assemblies @testdata.test_assembly
    nunit.options '/noshadow'
    
    ncc.testrunner = nunit
    ncc.run
  end

  
  it "should produce the xml report" do
    File.exist?(@testdata.xml_coverage_output).should == true
  end
  
  it "should produce the html report" do
    File.exist?(@testdata.html_coverage_output).should == true
  end
end

describe NCoverConsole, "when producing a report with machine.specifications" do
  before :all do
  	@testdata = NCoverConsoleTestData.new
    @ncc = NCoverConsole.new()
    
    @ncc.extend(SystemPatch)
    @ncc.log_level = :verbose
    @ncc.path_to_command = @testdata.ncoverpath
    @ncc.output :xml => @testdata.xml_coverage_output
    @ncc.working_directory = @testdata.working_directory
    
    mspec = MSpecTestRunner.new(@testdata.mspecpath)
    mspec.assemblies @testdata.mspec_test_assembly
    mspec.html_output = @testdata.mspec_html_output
    
    @ncc.testrunner = mspec
    @ncc.run
  end

  it "should not fail" do
    @ncc.failed.should be_false
  end

  it "should produce the html report" do
    File.exist?(@testdata.mspec_html_output.to_s).should be_true
  end

end
