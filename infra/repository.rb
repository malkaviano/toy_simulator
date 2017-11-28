module Generics
  module Repository
    def add(obj)
      result = find obj.name
      
      raise "object already exists" unless result.nil?
      
      @repository[obj.name.to_sym] = obj
    end

    def remove(name)
      @repository.delete name.to_sym
    end
    
    def all
      @repository.values
    end
    
    def find(name)
      @repository[name.to_sym]
    end
    
    def clear
      @repository = {}
    end
  end
end
