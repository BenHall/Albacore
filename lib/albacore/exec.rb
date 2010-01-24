require 'albacore/support/albacore_helper'

class Exec
<<<<<<< HEAD
  extend AttrMethods
  include RunCommand
  include YAMLConfig
  include Logging
  
  attr_array :parameters
  
  def initialize
    @path_to_command=''
    @parameters = []
    super()
  end
    
  def execute
    result = run_command "Exec", @parameters.join(" ")
    
    failure_message = 'Exec Failed. See Build Log For Detail'
    fail_with_message failure_message if !result
  end
=======
	include RunCommand
	include YAMLConfig
	include Logging
	
	attr_accessor :command, :parameters
	
	def initialize
		super()
	end
		
	def execute
		command_to_execute = []
		command_to_execute << "\"#{@command}\""
		command_to_execute << @parameters if parameters
		   
    begin
      system command_to_execute.join(" ")
    rescue 
      failure_message = "#{@command} Failed. See Build Log For Detail"
      raise failure_message
    end
	end
>>>>>>> e71331df3fa4a9df0fbb7b4fd93a3d3d1cc35605
end
