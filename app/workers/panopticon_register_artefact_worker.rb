require 'plek'
require 'gds_api/panopticon'

class PanopticonRegisterArtefactWorker < WorkerBase
  sidekiq_options queue: :panopticon

  def perform(edition_id, options = {})
    edition = Edition.find(edition_id)

    if edition.present?
      registerable_edition = RegisterableEdition.new(edition)
      registerer           = Whitehall.panopticon_registerer_for(registerable_edition)
      registerer.register(registerable_edition)

      if edition.public_url_changed_from_previous_edition?
        
      end
    end
  end
end
