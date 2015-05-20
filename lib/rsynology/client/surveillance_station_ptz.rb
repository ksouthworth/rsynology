require 'rsynology/client/api'

module RSynology
  class Client
    class SurveillanceStationPtz < API

      DIRECTION = {
        right: "dir_0",
        right_up: "dir_1",
        up: "dir_2",
        left_up: "dir_3",
        left: "dir_4",
        left_down: "dir_5",
        down: "dir_6",
        right_down: "dir_7"
      }

      def self.api_name
        'SYNO.SurveillanceStation.PTZ'
      end

      def move_url(camera_id, direction)
        params = {
          method: "Move",
          version: @maxVersion,
          api: api_name,
          _sid: @client.session_id,
          cameraId: camera_id,
          direction: direction,
          speed: 5 # fast
        }

        "#{@client.connection.url_prefix.to_s.chomp('/')}/webapi/#{@endpoint}?#{params.to_query}"
      end

    end
  end
end
