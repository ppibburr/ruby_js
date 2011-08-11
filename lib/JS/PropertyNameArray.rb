module JS
  class PropertyNameArray < JS::Lib::PropertyNameArray

    def retain()
      res = super(self)
      return JS::PropertyNameArray.new(res)
    end

    def release()
      res = super(self)
      return res
    end

    def get_count()
      res = super(self)
      return res
    end

    def get_name_at_index(index)
      res = super(self,index)
      return JS.read_string(res)
    end
  end
end
