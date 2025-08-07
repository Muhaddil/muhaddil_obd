# Muhaddil OBD System for FiveM

## Overview
A comprehensive On-Board Diagnostics (OBD) system for FiveM servers, designed to work with both ESX and QBCore frameworks with the script JG-mechanic. This script allows mechanics or users to diagnose vehicle issues through a tablet interface, displaying vehicle data and maintenance information.

## Features
- **Framework Compatibility**: Automatically detects and works with both ESX and QBCore frameworks
- **Interactive OBD Tablet**: User-friendly interface for vehicle diagnostics
- **Real-time Vehicle Data**: Displays engine temperature, RPM, fuel level, and body condition
- **Maintenance Tracking**: Shows the status of various vehicle components including:
  - Engine components (oil, spark plugs, motor, coolant)
  - Performance components (air filter, suspension, clutch, tires, brake pads)
  - Diagnostic components (battery, temp, and more...)
- **Multiple UI Options**: Choose between standard or minimalistic interface
- **Item Integration**: Can be used as an inventory item
- **Customizable Settings**: Adjust scan distance, notifications, and more

## Requirements
- ESX or QBCore framework
- JG-mechanic
- ox_lib
- mysql-async or oxmysql

## Installation
1. Extract the resource to your server's resources folder
2. Add `ensure muhaddil_obd` to your server.cfg
3. Make sure the required dependencies are installed and running
4. Restart your server

## Configuration
The script can be configured through the `config.lua` file:

```lua
Config = {}

Config.ScanDistance = 2.5 -- Distance to scan for vehicles
Config.EnableKeyOpen = false -- Enable if you want to use a key to open the OBD tablet
Config.OpenKey = 'F5' -- Key to open the OBD tablet 
Config.DebugMode = false -- Enables debug mode for additional logging and use of commands
Config.ShowNotifications = true -- Show notifications when actions are performed
Config.UseOXNotifications = true -- Use OX notifications if available, otherwise fallback to framework notifications
Config.FrameWork = "auto" -- Set the framework to use, options are "auto", "esx" or "qb"
```

## Usage

### As an Item
The script registers an usable item called 'obd'. When used, it will open the OBD tablet if the player is near a vehicle.

### With Key Binding
If `Config.EnableKeyOpen` is set to `true`, players can use the configured key (default: F5) to open the OBD tablet when near a vehicle.

### Debug Mode
If `Config.DebugMode` is set to `true`, an additional command `/obd` will be available to open the tablet.

## UI Options
The script comes with two UI options:
1. **Standard UI**: A full-featured tablet interface with animations and detailed information
2. **Minimalistic UI**: A simpler interface for lower-end computers

To switch between UIs, edit the `fxmanifest.lua` file and comment/uncomment the appropriate lines as indicated in the file.

## Database Integration
The script reads vehicle data from the `mechanic_vehicledata` table in your database, specifically looking for the following information:
- Vehicle plate
- Servicing data (engine oil, spark plugs, brake pads, etc.)

## Credits
- Muhaddil