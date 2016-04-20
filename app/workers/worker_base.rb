class WorkerBase
  include Sidekiq::Worker

  def self.perform_async(*args)
    args << request_id_argument
    super(*args)
  end

  def self.perform_async_in_queue(queue, *args)
    args << request_id_argument
    client_push('class' => self, 'args' => args, 'queue' => queue || get_sidekiq_options["queue"])
  end

  def self.request_id_argument
    {request_id: GdsApi::GovukHeaders.headers[:govuk_request_id]}
  end
  private_class_method :request_id_argument

  def perform(*args)
    request_id = args.pop["request_id"]
    GdsApi::GovukHeaders.set_header(:govuk_request_id, request_id)
    perform_with_request_tracing(*args)
  end
end
