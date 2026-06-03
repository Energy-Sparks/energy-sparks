# in the abscence of a hash deep_merge in non-rails code:
# https://stackoverflow.com/questions/9381553/ruby-merge-nested-hash
# using HashRecursive
module HashRecursive
  refine Hash do
      def merge(other_hash, recursive=false, &block)
          if recursive
              block_actual = Proc.new {|key, oldval, newval|
                  newval = block.call(key, oldval, newval) if block_given?
                  [oldval, newval].all? {|v| v.is_a?(Hash)} ? oldval.merge(newval, &block_actual) : newval
              }
              self.merge(other_hash, &block_actual)
          else
              super(other_hash, &block)
          end
      end
      def merge!(other_hash, recursive=false, &block)
          if recursive
              self.replace(self.merge(other_hash, recursive, &block))
          else
              super(other_hash, &block)
          end
      end
  end
end
