require 'rsynology'
require 'hashie/trash'

module RSynology
  class Client
    class SurveillanceStationEvent < API

      class Event < Hashie::Trash
        include Hashie::Extensions::IgnoreUndeclared
        include Hashie::Extensions::IndifferentAccess

        TIME_TRANSFORM = lambda { |epoch| Time.at(epoch) }
        property :id
        property :event_id, from: :eventId
        property :camera_id, from: :cameraId
        property :camera_name
        property :event_size, from: :eventSize
        property :frame_count, from: :frameCount
        property :mode
        property :start_time, from: :startTime, with: TIME_TRANSFORM
        property :stop_time, from: :stopTime, with: TIME_TRANSFORM
        property :status
        property :reason
        property :video_codec, from: :videoCodec
        property :owner_id, from: :ownerDsId
        property :name
        property :path
        property :download_url
        property :download_type

        def duration
          stop_time - start_time
        end

        def reason_name
          return case reason
            when 2
              'motion'
            when 3
              'alarm'
            when 4
              'custom'
            when 5
              'manual'
          end
        end
      end

      def self.api_name
        'SYNO.SurveillanceStation.Event'
      end

      def query(params = {})
        default_params = {
          offset: 0,
          limit: 10,
          mode: nil,
          locked: nil,
          camera_ids: nil,
          from_time: nil,
          to_time: nil
        }

        merged_params = default_params.merge(params).reject do |k, v|
          v.nil?
        end

        resp = request("Query", merged_params)
        event_collection = handle_response(resp)

        events = []
        event_collection['events'].each do |event|
          e = Event.new(event)
          e.download_type = e.path.split(".").last
          e.download_url = download_url(e.event_id, "#{e.camera_name}-#{e.start_time.strftime('%Y-%m-%d-%H-%M-%S')}.#{e.download_type}")
          events << e
        end
        events
      end

      def download_url(event_id, filename = 'download.mp4')
        params = {
          method: "Download",
          version: @maxVersion,
          api: api_name,
          _sid: @client.session_id,
          eventId: event_id
        }

        "#{@client.connection.url_prefix.to_s.chomp('/')}/webapi/#{@endpoint}/#{filename}?#{params.to_query}"
      end

    end
  end
end
