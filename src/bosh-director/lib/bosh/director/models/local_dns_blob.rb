module Bosh::Director::Models
  class LocalDnsBlob < Sequel::Model(Bosh::Director::Config.db)
    many_to_one :blob, :class => 'Bosh::Director::Models::Blob'

    def self.latest
      Bosh::Director::Config.db.transaction(:isolation => :committed, :retry_on => [Sequel::SerializationFailure]) do
        LocalDnsBlob.where(version: LocalDnsBlob.max(:version)).first
      end
    end
  end
end
