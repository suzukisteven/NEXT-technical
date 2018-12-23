class House < ApplicationRecord

  filterrific(
    default_filter_params:
      { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_query,
      :with_name,
      :with_address,
      :with_rented
    ]
  )

  # ----- Define Scopes ----- #

  # scope :search_query, lambda { |query|
  #   # Searches the students table on the 'first_name' and 'last_name' columns.
  #   # Matches using LIKE, automatically appends '%' to each term.
  #   # LIKE is case INsensitive with MySQL, however it is case
  #   # sensitive with PostGreSQL. To make it work in both worlds,
  #   # we downcase everything.
  #   return nil  if query.blank?
  #
  #   # condition query, parse into individual keywords
  #   terms = query.downcase.split(/\s+/)
  #
  #   # replace "*" with "%" for wildcard searches,
  #   # append '%', remove duplicate '%'s
  #   terms = terms.map { |e|
  #     (e.gsub('*', '%') + '%').gsub(/%+/, '%')
  #   }
  #   # configure number of OR conditions for provision
  #   # of interpolation arguments. Adjust this if you
  #   # change the number of OR conditions.
  #   num_or_conds = 2
  #   where(
  #     terms.map { |term|
  #       "(LOWER(houses.name) LIKE ? OR LOWER(houses.address) LIKE ?)"
  #     }.join(' AND '),
  #     *terms.map { |e| [e] * num_or_conds }.flatten
  #   )
  # }

  scope :search_query, -> (values) { where("name iLike ? OR address iLike ?", "%#{values}%", "%#{values}%") }

  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
      when /^created_at/
        order("houses.created_at #{ direction }")
      when /^name/
        order("LOWER(houses.name) #{ direction }")
      when /^address/
        order("LOWER(houses.address) #{ direction }")
      when /^rented/
        order("(houses.rented) #{ direction }")
      else
        raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_name, lambda { |name|
    where(name: [*name])
  }

  scope :with_address, lambda { |address|
    where(address: [*address])
  }

  scope :with_rented, lambda { |rented|
    where(rented: [*rented])
  }

  scope :with_created_at_gte, lambda { |ref_date|
    where('houses.created_at >= ?',
      Date.strptime(ref_date, "%m/%d/%Y"))
    }

  def self.options_for_sorted_by
    [
      ['Name (A-Z)', 'name_asc'],
      ['Created At (Newest first)', 'created_at_desc'],
      ['Created At (Oldest first)', 'created_at_asc'],
      ['Rental Status (Rented)', 'rented_desc'],
      ['Rental Status (Not rented)', 'rented_asc']
    ]
  end

  def self.options_for_select
    order('LOWER(address)').map { |e| [e.address] }
  end

  def self.options_for_rented_status
    [true, false]
  end

end
