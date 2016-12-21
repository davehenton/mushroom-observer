class Query::ObservationAll < Query::ObservationBase
  include Query::Initializers::All

  def initialize_flavor
    add_sort_order_to_title
    super
  end
end