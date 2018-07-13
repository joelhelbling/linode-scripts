module Api
  class Stackscript
    class << self
      include Collectionate
      include Api::Utils

      def source_from(label)
        find(label).script
      end

      def create(label, options)
        api.stackscript.create \
          Label: label,
          Description: options[:description],
          DistributionIDList: distribution_from(options),
          isPublic: false,
          rev_note: options[:comment],
          script: read_local(label)
      end

      def update(label, options)
        api.stackscript.update \
          StackScriptID: id_from(label),
          Label: label,
          Description: options[:description],
          DistributionIDList: distribution_from(options),
          isPublic: false,
          rev_note: options[:comment],
          script: read_local(label)
      end

      def delete(label)
        api.stackscript.delete \
          StackScriptID: Api::Stackscript.id_from(label)
      end

      private

      def distribution_from(options)
        Api::Distribution.id_from options[:distribution]
      end

      def collection
        api.stackscript.list
      end

      def make_table_row(script)
        {
          id: script.stackscriptid,
          label: script.label,
          updated: script.rev_dt,
          deployments: "#{script.deploymentsactive}/#{script.deploymentstotal}",
          note: script.rev_note
        }
      end
    end
  end
end
