module ::Guard
  class JavaTranslator
    class << self
      def filename_to_classname(filename_path, src_root_path='src/')
        klass = filename_path.gsub(src_root_path, '').gsub('/', '.').gsub('.java', '')
        klass = klass[1..-1] if klass[0] == '.'
        klass
      end
    end
  end
end

