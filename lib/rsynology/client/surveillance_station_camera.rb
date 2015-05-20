require 'rsynology/api'
require 'hashie'

module RSynology
  class Client
    class SurveillanceStationCamera < API

      class Camera < Hashie::Trash
        include Hashie::Extensions::IgnoreUndeclared
        include Hashie::Extensions::IndifferentAccess

        property :id
        property :status
        property :name
        property :model
        property :vendor
        property :snapshot_path
        property :snapshot_url
        property :video_flip
        property :video_mirror
        property :video_rotation

        def status_name
          return case status
            when 0
              'normal'
            when 2
              'disconnected'
          end
        end
      end

      def self.api_name
        'SYNO.SurveillanceStation.Camera'
      end

      def list(params = {})
        resp = request("List", params, 1)
        reply = handle_response(resp)

        cameras = []
        reply['cameras'].each do |data|
          c = Camera.new(data)
          c.snapshot_url = snapshot_url(c.id)
          cameras << c
        end
        cameras
      end

      def snapshot_url(camera_id)

        params = {
          method: "GetSnapshot",
          version: @maxVersion,
          api: api_name,
          _sid: @client.session_id,
          cameraId: camera_id
        }

        "#{@client.connection.url_prefix.to_s.chomp('/')}/webapi/#{@endpoint}?#{params.to_query}"
      end

    end
  end
end
