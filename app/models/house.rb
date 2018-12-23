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

  # scope :search_query, -> (values) { where("name iLike ? OR address iLike ?", "%#{values}%", "%#{values}%") }
  scope :search_query, lambda { |query|
    # Searches the students table on the 'first_name' and 'last_name' columns.
    # Matches using LIKE, automatically appends '%' to each term.
    # LIKE is case INsensitive with MySQL, however it is case
    # sensitive with PostGreSQL. To make it work in both worlds,
    # we downcase everything.
    return nil  if query.blank?

    # condition query, parse into individual keywords
    terms = query.downcase.split(/\s+/)

    # replace "*" with "%" for wildcard searches,
    # append '%', remove duplicate '%'s
    terms = terms.map { |e|
      (e.gsub('*', '%') + '%').gsub(/%+/, '%')
    }
    # configure number of OR conditions for provision
    # of interpolation arguments. Adjust this if you
    # change the number of OR conditions.
    num_or_conds = 2
    where(
      terms.map { |term|
        "(LOWER(house.name) LIKE ? OR LOWER(house.address) LIKE ?)"
      }.join(' AND '),
      *terms.map { |e| [e] * num_or_conds }.flatten
    )
  }

  # scope :sorted_by, lambda { |sort_option|
  #   # extract the sort direction from the param value.
  #   direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
  #   case sort_option.to_s
  #   when /^created_at_/
  #     # Simple sort on the created_at column.
  #     # Make sure to include the table name to avoid ambiguous column names.
  #     # Joining on other tables is quite common in Filterrific, and almost
  #     # every ActiveRecord table has a 'created_at' column.
  #     order("houses.created_at #{ direction }")
  #   when /^name_/
  #     # Simple sort on the name colums
  #     order("LOWER(houses.name) #{ direction }")
  #   when /^address_/
  #     # This sorts by a student's country name, so we need to include
  #     # the country. We can't use JOIN since not all students might have
  #     # a country.
  #     order("LOWER(address) #{ direction }").includes(:address).references(:address)
  #   else
  #     raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
  #   end
  # }
  #
  scope :sorted_by, lambda { |sort_option|
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at/
      order("houses.created_at #{ direction }")
    when /^name/
      order("LOWER(house.name) #{ direction }")
    when /^address/
      order("LOWER(house.address) #{ direction }")
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
    where('house.created_at >= ?',
      Date.strptime(ref_date, "%m/%d/%Y"))
    }

  def self.options_for_sorted_by
    [
      ['Name (a-z)', 'name_asc'],
      ['Address (newest first)', 'created_at_desc'],
      ['Address (oldest first)', 'created_at_asc'],
      ['Rented', 'true_desc']
    ]
  end

  def self.options_for_select
    order('LOWER(address)').map { |e| [e.address, e.id] }
  end

end
