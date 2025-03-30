class Inventory
  def initialize(json)
    @json = json
  end

  def success?
    return @json["result"][0]["status"] == 200
  end

  def devices
    return @json["result"][0]["devices"]
  end

  def device_summary
    devices.map do |device|
        OpenStruct.new(
          id: device["deviceId"],
          type: device["deviceType"],
          commissioned: device["dateCommissioned"],
          smets_version: device["smetsChtsVersion"],
          gbcs_version: device["deviceGbcsVersion"]
        )
    end
  end
end
