const fz = require('zigbee-herdsman-converters/converters/fromZigbee');
const tz = require('zigbee-herdsman-converters/converters/toZigbee');
const exposes = require('zigbee-herdsman-converters/lib/exposes');
const reporting = require('zigbee-herdsman-converters/lib/reporting');
const extend = require('zigbee-herdsman-converters/lib/extend');
const e = exposes.presets;
const ea = exposes.access;

const definition = {
  // Didn't receive a model id, because it's unable to pair
    zigbeeModel: ['SHUNCOM-R-001'], // The model ID from: Device with modelID 'lumi.sens' is not supported.
    model: 'SHUNCOM-R-001', // Vendor model number, look on the device for a model number
    vendor: 'HiSense', // Vendor of the device (only used for documentation and startup logging)
    description: 'Samrt Wall Socket', // Description of the device, copy from vendor site. (only used for documentation and startup logging)
    extend: extend.switch({disablePowerOnBehavior: true}),
    fromZigbee: [fz.on_off_skip_duplicate_transaction],
    configure: async (device, coordinatorEndpoint, logger) => {
        const endpoint = device.getEndpoint(1);
        await reporting.bind(endpoint, coordinatorEndpoint, ['genOnOff']);
    },
    onEvent: async (type, data, device) => {
        device.skipDefaultResponse = true;
    },
};

module.exports = definition;
