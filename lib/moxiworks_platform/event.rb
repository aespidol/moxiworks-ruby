module MoxiworksPlatform
  # = Moxi Works Platform Event
  class Event < MoxiworksPlatform::Resource
    # @!attribute moxi_works_agent_id
    #   moxi_works_agent_id is the Moxi Works Platform ID of the agent which a event is
    #   or is to be associated with.
    #
    #   this must be set for any Moxi Works Platform transaction
    #
    #   @return [String] the Moxi Works Platform ID of the agent
    attr_accessor :moxi_works_agent_id

    # @!attribute partner_event_id
    # your system's event ID for the event
    #
    # @return [String] representing the ID of the event in your system
    attr_accessor :partner_event_id

    # @!attribute event_subject
    # a short description of the event
    #
    # @return [String]
    attr_accessor :event_subject

    # @!attribute location
    # a short description of the location of the event
    #
    # @return [String]
    attr_accessor :event_location

    # @!attribute note
    # a more detailed description of the event
    #
    # @return [String]
    attr_accessor :note

    # @!attribute send_reminder
    # whether a reminder should be sent to the agent
    #
    # @return [Boolean]
    attr_accessor :send_reminder

    # @!attribute remind_minutes_before
    # how many minutes before the event a reminder should be sent (if send_reminder is true)
    #
    # @return [Integer]
    attr_writer :remind_minutes_before

    # @!attribute is_meeting
    # whether this event is a meeting
    #
    # @return [Boolean]
    attr_accessor :is_meeting

    # @!attribute event_start
    # a unix timestamp representing the start time of the event
    #
    # @return [Integer]
    attr_writer :event_start

    # @!attribute event_end
    # a unix timestamp representing the end time of the event
    #
    # @return [Integer]
    attr_writer :event_end

    # @!attribute recurring
    # whether the event is recurring
    #
    # @return [Boolean]
    attr_accessor :recurring

    # @!attribute all_day
    # whether the event is an all day event
    #
    # @return [Boolean]
    attr_accessor :all_day


    # Creates a new Event in Moxi Works Platform
    # @param [Hash] opts named parameter Hash
    # @option opts [String]  :moxi_works_agent_id *REQUIRED* The Moxi Works Agent ID for the agent to which this event is to be associated
    # @option opts [String]  :partner_event_id *REQUIRED* Your system's unique ID for this event.
    #
    #     optional Event parameters
    #
    # @option opts [String] :event_subject  a brief human-readable description of the event
    # @option opts [String] :event_location human-readable description of the event's location
    # @option opts [String] :note human-readable details regarding the event
    # @option opts [Boolean] :send_reminder whether a reminder should be sent beforehand
    # @option opts [Integer] :remind_minutes_before how many minutes before the event the reminder should be sent (if send_reminder is true)
    # @option opts [Boolean] :is_meeting whether the event is a meeting
    # @option opts [Integer] :event_start Unix timestamp representing the start time of the event
    # @option opts [Integer] :event_end Unix timestamp representing the end time of the event
    # @option opts [Boolean] :recurring whether the event is a recurring event
    # @option opts [Boolean] :all_day whether the event is an all day event
    #
    # @return [MoxiworksPlatform::Event]
    #
    # @raise ::MoxiworksPlatform::Exception::ArgumentError if required
    #     named parameters aren't included
    #
    # @example
    #   MoxiworksPlatform::Event.create(
    #         partner_event_id: 'mySystemsUniqueEventID',
    #         event_subject: 'foo deeaz',
    #         event_location: '1234 there ave',
    #         note: 'yo, whatup?',
    #         send_reminder: true,
    #         remind_minutes_before: 10,
    #         is_meeting: true,
    #         event_start: Time.now.to_i,
    #         event_end: Time.now.to_i + 86400,
    #         recurring: false,
    #         all_day: false
    #     )
    #
    def self.create(opts={})
       self.send_request(:post, opts)
     end

    # Find an Event  your system has previously created in Moxi Works Platform
    # @param [Hash] opts named parameter Hash
    # @option opts [String]  :moxi_works_agent_id *REQUIRED* The Moxi Works Agent ID for the agent to which this event is associated
    # @option opts [String]  :partner_event_id *REQUIRED* Your system's unique ID for this event.
    #
    # @return [MoxiworksPlatform::Event]
    #
    # @raise ::MoxiworksPlatform::Exception::ArgumentError if required
    #     named parameters aren't included
    #
    def self.find(opts={})
      url = "#{MoxiworksPlatform::Config.url}/api/events/#{opts[:partner_event_id]}"
      self.send_request(:get, opts, url)
    end


    # Search an Agent's Events in Moxi Works Platform
    # @param [Hash] opts named parameter Hash
    # @option opts [String]  :moxi_works_agent_id *REQUIRED* The Moxi Works Agent ID for the agent to which this event is associated
    # @option opts [Integer]  :date_start *REQUIRED* The Unix timestamp representing the date after which to search
    # @option opts [Integer]  :date_end *REQUIRED* The Unix timestamp representing the date before which to search
    #
    # @return [Array] containing Hash objects formatted as follows:
    #   {   "date" => "MM/DD/YY",
    #       "events" => [ MoxiworkPlatform::Event, MoxiworkPlatform::Event ]
    #   }
     #
    # @raise ::MoxiworksPlatform::Exception::ArgumentError if required
    #     named parameters aren't included
    #
    # @example
    #     results = MoxiworksPlatform::Contact.search(
    #     moxi_works_agent_id: '123abc',
    #     date_start: Time.now - 60 * 60 * 24 * 7, # 1 week
    #     date_end: Time.now
    #       )
    #
    def self.search(opts={})
      url ||= "#{MoxiworksPlatform::Config.url}/api/events"
      required_opts = [:moxi_works_agent_id, :date_start, :date_end]
      required_opts.each do |opt|
        raise ::MoxiworksPlatform::Exception::ArgumentError, "#{opt} required" if
            opts[opt].nil? or opts[opt].empty?
      end
      results = []
      RestClient::Request.execute(method: :get,
                                  url: url,
                                  payload: opts, headers: self.headers) do |response|
        puts response if MoxiworksPlatform::Config.debug
        self.check_for_error_in_response(response)
        json = JSON.parse(response)
        json.each do |events_for_date|
          events = []
          events_for_date.each do |date, event_array|
            event_array.each do |r|
              events << MoxiworksPlatform::Event.new(r) unless r.nil? or r.empty?
            end
            results << {date: date, events: events}
          end
        end
      end
      results
    end

    # Updates a new Event in Moxi Works Platform
    # @param [Hash] opts named parameter Hash
    # @option opts [String]  :moxi_works_agent_id *REQUIRED* The Moxi Works Agent ID for the agent to which this event is to be associated
    # @option opts [String]  :partner_event_id *REQUIRED* Your system's unique ID for this event.
    #
    #     optional Event parameters
    #
    # @option opts [String] :event_subject  a brief human-readable description of the event
    # @option opts [String] :event_location human-readable description of the event's location
    # @option opts [String] :note human-readable details regarding the event
    # @option opts [Boolean] :send_reminder whether a reminder should be sent beforehand
    # @option opts [Integer] :remind_minutes_before how many minutes before the event the reminder should be sent (if send_reminder is true)
    # @option opts [Boolean] :is_meeting whether the event is a meeting
    # @option opts [Integer] :event_start Unix timestamp representing the start time of the event
    # @option opts [Integer] :event_end Unix timestamp representing the end time of the event
    # @option opts [Boolean] :recurring whether the event is a recurring event
    # @option opts [Boolean] :all_day whether the event is an all day event
    #
    # @return [MoxiworksPlatform::Event]
    #
    # @raise ::MoxiworksPlatform::Exception::ArgumentError if required
    #     named parameters aren't included
    #
    # @example
    #   MoxiworksPlatform::Event.update(
    #         partner_event_id: 'mySystemsUniqueEventID',
    #         event_subject: 'foo deeaz',
    #         event_location: '1234 there ave',
    #         note: 'yo, whatup?',
    #         send_reminder: true,
    #         remind_minutes_before: 10,
    #         is_meeting: true,
    #         event_start: Time.now.to_i,
    #         event_end: Time.now.to_i + 86400,
    #         recurring: false,
    #         all_day: false
    #     )
    #
    def self.update(opts={})
       opts[:event_id] = opts[:partner_event_id]
       url = "#{MoxiworksPlatform::Config.url}/api/events/#{opts[:partner_event_id]}"
       self.send_request(:put, opts, url)
     end

    # Delete an Event your system has previously created in Moxi Works Platform
    # @param [Hash] opts named parameter Hash
    #
    #     required parameters
    #
    # @option opts [String]  :moxi_works_agent_id *REQUIRED* The Moxi Works Agent ID for the agent to which this event is associated
    # @option opts [String]  :partner_event_id *REQUIRED* Your system's unique ID for this event.
    #
    # @return [Boolean] -- success of the delete action
    #
    # @raise ::MoxiworksPlatform::Exception::ArgumentError if required
    #     named parameters aren't included
    #
    # @example
    #   success = MoxiWorksPlatform::Event.delete(moxi_works_agent_id: '123abcd', partner_event_id: 'myUniqueEventId' )
    #
    def self.delete(opts={})
      url = "#{MoxiworksPlatform::Config.url}/api/events/#{opts[:partner_event_id]}"
      required_opts = [:moxi_works_agent_id, :partner_event_id]
      required_opts.each do |opt|
        raise ::MoxiworksPlatform::Exception::ArgumentError, "#{opt} required" if
            opts[opt].nil? or opts[opt].empty?
      end
      RestClient::Request.execute(method: :delete,
                                  url: url,
                                  payload: opts, headers: self.headers) do |response|
        puts response if MoxiworksPlatform::Config.debug
        json = JSON.parse(response)
        raise ::MoxiworksPlatform::Exception::RemoteRequestFailure,
              'unable to delete' if json['status'] == 'error'
        json['status'] == 'success'
      end
    end

    # Send our remote request to the Moxi Works Platform
    #
    # @param [String] method The HTTP method to be used when connecting; ex: :put, :post, :get
    # @param [Hash] opts
    # @option opts [String]  :moxi_works_agent_id *REQUIRED* The Moxi Works Agent ID for the agent to which this event is associated
    # @option opts [String]  :partner_event_id *REQUIRED* Your system's unique ID for this event.
    #
    #     optional Event parameters
    #
    # @option opts [String] :event_subject  a brief human-readable description of the event
    # @option opts [String] :event_location human-readable description of the event's location
    # @option opts [String] :note human-readable details regarding the event
    # @option opts [Boolean] :send_reminder whether a reminder should be sent beforehand
    # @option opts [Integer] :remind_minutes_before how many minutes before the event the reminder should be sent (if send_reminder is true)
    # @option opts [Boolean] :is_meeting whether the event is a meeting
    # @option opts [Integer] :event_start Unix timestamp representing the start time of the event
    # @option opts [Integer] :event_end Unix timestamp representing the end time of the event
    # @option opts [Boolean] :recurring whether the event is a recurring event
    # @option opts [Boolean] :all_day whether the event is an all day event
    #
    # @return [MoxiworksPlatform::Event]
    #
    # @raise ::MoxiworksPlatform::Exception::ArgumentError if required
    #     named parameters aren't included
    #
    def self.send_request(method, opts={}, url=nil)
      url ||= "#{MoxiworksPlatform::Config.url}/api/events"
      required_opts = [:moxi_works_agent_id, :partner_event_id]
      required_opts.each do |opt|
        raise ::MoxiworksPlatform::Exception::ArgumentError, "#{opt} required" if
            opts[opt].nil? or opts[opt].empty?
      end
      opts[:event_id] = opts[:partner_event_id]
      super(method, opts, url)
    end

    # Save an instance of MoxiWorksPlatform::Event to Moxi Works Platform
    #
    # @return [MoxiWorksPlatform:Event]
    #
    # @example
    #   event = MoxiWorksPlatform::Event.new()
    #   event.moxi_works_agent_id = '123abcd'
    #   event.partner_event_id = 'myUniqueEventdentifier'
    #   event.event_start =  Time.now.to_i
    #   event.save
    def save
      MoxiworksPlatform::Event.update(self.to_hash)
    end

    # Delete an instance of MoxiWorksPlatform::Event from Moxi Works Platform that your system has previously created
    #
    # @return [Boolean] -- success of the delete action
    #
    # @example
    #   event = MoxiWorksPlatform::Event.find(moxi_works_agent_id: '123abcd', partner_event_id: 'myUniqueEventtId' )
    #   success = event.delete
    #
    def delete
      MoxiworksPlatform::Event.delete(self.to_hash)
    end

    private

    def int_attrs
      [:remind_minutes_before, :event_start, :event_end]
    end


  end
end
