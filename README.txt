Compatibility

The indigolink app is for iOS 8 and above and has been written mainly in Swift but has part of the code in Objective-C as well.

The indigolink has been designed for the iPhone 6 plus model and will need adjustments in the storyboard for smaller screen size iPhones.

The indigolink app communicates with the indigolink server over TCP/IP, if you want to use it over the Internet then you need to open access to that port on your router from the 'outside'.

indigolink has been tested with:
- Motion Sensors (Fibaro, Philio)
- Sockets (TKB TZ88E, TKB TZ68E)
- Electricity Switches (Vitrum)
- Door/Window Sensors (Fibaro)
- Smake/Monoxice Sensors (Fibaro, ZS6301)
- Temperature Sensors (as part of a device)
- Luminance Sensors (as part of a device)
- Tamper Sensors (as part of a device)

Not compatible with:
- Gas/Electricity meters
- Thermostats

(...as I don't own such devices yet)

Requirements

To use the indigolink app you need to have:
- the indigo domotics software installed & running on your Mac (tested with 6.0.20) 
- the indigo domotics SQL Logger plugin enabled and using a PostgreSQL database (tested with 9.4.1)
- the indigolink server installed & running (on the same computer or other).

For the indigolink app to work correctly the "Device Name" within the indigo domotics software needs to be like this:

ROOM - DEVICE/LOCATION - FUNCTIONALITY

For example a Fibaro Door Sensor with the temperature module will have three devices like this:

Hallway - Front Door - Door Sensor
Hallway - Front Door - Tamper Switch
Hallway - Front Door - Temperature

in some cases where there is only one device this format can be used:

ROOM - FUNCTIONALITY

Kitchen - Carbon Monoxide Alarm

As manufacturers have different descriptions types (can't be edited within indigo) I have used this naming scheme to make things easier as with the name we can put there whatever we like. The app will still though look for certain references in the type.

Currently the app looks for the following strings:

- Light Switches: "Relay Power Switch" within the device type or device name
- Sockets: "Appliance Module" within the device type or device name
- Motion Sensors: "Motion" within the device type or device name
- Door/Window Sensors: "Door Sensor" or "Window Sensor" within the device type or device name
- Temperature Sensors: "Temperature" within the device name
- Smoke Sensors: "Smoke" or "Carbon" within the device type
- Luminance (light) Sensors: "Luminance" within the device name

Dependencies

The iPhone app uses:
- SocketRocket
- AEXML
- SwiftyJSON

To make the graphs work you will need to download a trial of Telerik iOS Chart component as I haven't managed to get CorePlot to work as I want to.

License

Licensed under the Apache License, Version 2.0.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
