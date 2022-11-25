import Foundation
import Vapor
import SwiftEccodes
import SwiftPFor2D


/// Might be used to decode API queries later
enum CerraVariable: String, CaseIterable, Codable, GenericVariable {
    case temperature_2m // ok
    /*case wind_u_component_100m // only model level
    case wind_v_component_100m
    case wind_u_component_10m // partly, speed and direction now, but model level available
    case wind_v_component_10m // partly*/
    case windspeed_10m
    case winddirection_10m
    case windgusts_10m  // ok
    //case dewpoint_2m // relative humidity nowc
    case relativehumidity_2m
    case cloudcover_low  // ok
    case cloudcover_mid  // ok
    case cloudcover_high  // ok
    case pressure_msl  // ok
    case snowfall_water_equivalent  // ok
    /*case soil_temperature_0_to_7cm  // special dataset now, with very fine grained spacing ~1-4cm
    case soil_temperature_7_to_28cm
    case soil_temperature_28_to_100cm
    case soil_temperature_100_to_255cm
    case soil_moisture_0_to_7cm
    case soil_moisture_7_to_28cm
    case soil_moisture_28_to_100cm
    case soil_moisture_100_to_255cm*/
    case shortwave_radiation // ok
    case precipitation // ok
    case direct_radiation // ok, probaly
    
    var isElevationCorrectable: Bool {
        return self == .temperature_2m
    }
    
    var omFileName: String {
        return rawValue
    }
    
    var interpolation: ReaderInterpolation {
        fatalError("Interpolation not required for cerra")
    }
    
    /// Name used to query the ECMWF CDS API via python
    var cdsApiName: String {
        switch self {
        /*case .wind_u_component_100m: return "100m_u_component_of_wind"
        case .wind_v_component_100m: return "100m_v_component_of_wind"
        case .wind_u_component_10m: return "10m_u_component_of_wind"
        case .wind_v_component_10m: return "10m_v_component_of_wind"*/
        case .windgusts_10m: return "10m_wind_gust_since_previous_post_processing"
        //case .dewpoint_2m: return "2m_dewpoint_temperature"
        case .relativehumidity_2m: return "2m_relative_humidity"
        case .temperature_2m: return "2m_temperature"
        case .cloudcover_low: return "low_cloud_cover"
        case .cloudcover_mid: return "medium_cloud_cover"
        case .cloudcover_high: return "high_cloud_cover"
        case .pressure_msl: return "mean_sea_level_pressure"
        case .snowfall_water_equivalent: return "snow_fall_water_equivalent"
        /*case .soil_temperature_0_to_7cm: return "soil_temperature_level_1"
        case .soil_temperature_7_to_28cm: return "soil_temperature_level_2"
        case .soil_temperature_28_to_100cm: return "soil_temperature_level_3"
        case .soil_temperature_100_to_255cm: return "soil_temperature_level_4"*/
        case .shortwave_radiation: return "surface_solar_radiation_downwards"
        case .precipitation: return "total_precipitation"
        case .direct_radiation: return "time_integrated_surface_direct_short_wave_radiation_flux"
        /*case .soil_moisture_0_to_7cm: return "volumetric_soil_water_layer_1"
        case .soil_moisture_7_to_28cm: return "volumetric_soil_water_layer_2"
        case .soil_moisture_28_to_100cm: return "volumetric_soil_water_layer_3"
        case .soil_moisture_100_to_255cm: return "volumetric_soil_water_layer_4"*/
        case .windspeed_10m:
            return "10m_wind_speed"
        case .winddirection_10m:
            return "10m_wind_direction"
        }
    }
    
    /// Applied to the netcdf file after reading
    var netCdfScaling: (offest: Double, scalefactor: Double) {
        switch self {
        /*case .wind_u_component_100m: return (0, 1)
        case .wind_v_component_100m: return (0, 1)
        case .wind_u_component_10m: return (0, 1)
        case .wind_v_component_10m: return (0, 1)*/
        case .windgusts_10m: return (0, 1)
        case .temperature_2m: return (-273.15, 1) // kelvin to celsius
        //case .dewpoint_2m: return (-273.15, 1)
        case .relativehumidity_2m: return (0, 1)
        case .cloudcover_low: return (0, 100) // fraction to percent
        case .cloudcover_mid: return (0, 100)
        case .cloudcover_high: return (0, 100)
        case .pressure_msl: return (0, 1) // keep in Pa (not hPa)
        case .snowfall_water_equivalent: return (0, 1000) // meter to millimeter
        /*case .soil_temperature_0_to_7cm: return (-273.15, 1) // kelvin to celsius
        case .soil_temperature_7_to_28cm: return (-273.15, 1)
        case .soil_temperature_28_to_100cm: return (-273.15, 1)
        case .soil_temperature_100_to_255cm: return (-273.15, 1)
        case .soil_moisture_0_to_7cm: return (0, 1)
        case .soil_moisture_7_to_28cm: return (0, 1)
        case .soil_moisture_28_to_100cm: return (0, 1)
        case .soil_moisture_100_to_255cm: return (0, 1)*/
        case .shortwave_radiation: return (0, 1/3600) // joules to watt
        case .precipitation: return (0, 1000) // meter to millimeter
        case .direct_radiation: return (0, 1/3600)
        case .windspeed_10m: return (0, 1)
        case .winddirection_10m: return (0, 1)
        }
    }
    
    /// Name in the resulting netCdf file from CDS API
    /*var netCdfName: String {
        switch self {
        case .wind_u_component_100m: return "v100"
        case .wind_v_component_100m: return "u100"
        case .wind_u_component_10m: return "v10"
        case .wind_v_component_10m: return "u10"
        case .windgusts_10m: return "i10fg"
        case .dewpoint_2m: return "d2m"
        case .temperature_2m: return "t2m"
        case .cloudcover_low: return "lcc"
        case .cloudcover_mid: return "mcc"
        case .cloudcover_high: return "hcc"
        case .pressure_msl: return "msl"
        case .snowfall_water_equivalent: return "sf"
        case .soil_temperature_0_to_7cm: return "stl1"
        case .soil_temperature_7_to_28cm: return "stl2"
        case .soil_temperature_28_to_100cm: return "stl3"
        case .soil_temperature_100_to_255cm: return "stl4"
        case .shortwave_radiation: return "ssrd"
        case .precipitation: return "tp"
        case .direct_radiation: return "fdir"
        case .soil_moisture_0_to_7cm: return "swvl1"
        case .soil_moisture_7_to_28cm: return "swvl2"
        case .soil_moisture_28_to_100cm: return "swvl3"
        case .soil_moisture_100_to_255cm: return "swvl4"
        }
    }*/
    
    /// Scalefactor to compress data
    var scalefactor: Float {
        switch self {
        /*case .wind_u_component_100m: return 10
        case .wind_v_component_100m: return 10
        case .wind_u_component_10m: return 10
        case .wind_v_component_10m: return 10*/
        case .cloudcover_low: return 1
        case .cloudcover_mid: return 1
        case .cloudcover_high: return 1
        case .windgusts_10m: return 10
        //case .dewpoint_2m: return 20c
        case .relativehumidity_2m: return 1
        case .temperature_2m: return 20
        case .pressure_msl: return 0.1
        case .snowfall_water_equivalent: return 10
        /*case .soil_temperature_0_to_7cm: return 20
        case .soil_temperature_7_to_28cm: return 20
        case .soil_temperature_28_to_100cm: return 20
        case .soil_temperature_100_to_255cm: return 20*/
        case .shortwave_radiation: return 1
        case .precipitation: return 10
        case .direct_radiation: return 1
        /*case .soil_moisture_0_to_7cm: return 1000
        case .soil_moisture_7_to_28cm: return 1000
        case .soil_moisture_28_to_100cm: return 1000
        case .soil_moisture_100_to_255cm: return 1000*/
        case .windspeed_10m: return 10
        case .winddirection_10m: return 0.5
        }
    }
    
    var unit: SiUnit {
        switch self {
        /*case .wind_u_component_100m: fallthrough
        case .wind_v_component_100m: fallthrough
        case .wind_u_component_10m: fallthrough
        case .wind_v_component_10m: fallthrough*/
        case .windspeed_10m: fallthrough
        case .windgusts_10m: return .ms
        case .winddirection_10m: return .degreeDirection
        //case .dewpoint_2m: return .celsius
        case .relativehumidity_2m: return .percent
        case .temperature_2m: return .celsius
        case .cloudcover_low: return .percent
        case .cloudcover_mid: return .percent
        case .cloudcover_high: return .percent
        case .pressure_msl: return .pascal
        case .snowfall_water_equivalent: return .millimeter
        /*case .soil_temperature_0_to_7cm: return .celsius
        case .soil_temperature_7_to_28cm: return .celsius
        case .soil_temperature_28_to_100cm: return .celsius
        case .soil_temperature_100_to_255cm: return .celsius*/
        case .shortwave_radiation: return .wattPerSquareMeter
        case .precipitation: return .millimeter
        case .direct_radiation: return .wattPerSquareMeter
        /*case .soil_moisture_0_to_7cm: return .qubicMeterPerQubicMeter
        case .soil_moisture_7_to_28cm: return .qubicMeterPerQubicMeter
        case .soil_moisture_28_to_100cm: return .qubicMeterPerQubicMeter
        case .soil_moisture_100_to_255cm: return .qubicMeterPerQubicMeter*/
        }
    }
}

struct DownloadCerraCommand: Command {
    struct Signature: CommandSignature {
        @Option(name: "timeinterval", short: "t", help: "Timeinterval to download with format 20220101-20220131")
        var timeinterval: String?
        
        @Option(name: "year", short: "y", help: "Download one year")
        var year: String?
        
        @Option(name: "stripseaYear", short: "s", help: "strip sea of converted files")
        var stripseaYear: String?
        
        @Option(name: "cdskey", short: "k", help: "CDS API user and key like: 123456:8ec08f...")
        var cdskey: String?
        
        @Flag(name: "force", short: "f", help: "Force to update given timeinterval, regardless if files could be downloaded")
        var force: Bool
        
        @Flag(name: "hourlyfiles", help: "Download hourly files instead of daily files")
        var hourlyFiles: Bool
        
        /// Get the specified timerange in the command, or use the last 7 days as range
        func getTimeinterval() -> TimerangeDt {
            let dt = hourlyFiles ? 3600 : 86400
            if let timeinterval = timeinterval {
                guard timeinterval.count == 17, timeinterval.contains("-") else {
                    fatalError("format looks wrong")
                }
                let start = Timestamp(Int(timeinterval[0..<4])!, Int(timeinterval[4..<6])!, Int(timeinterval[6..<8])!)
                let end = Timestamp(Int(timeinterval[9..<13])!, Int(timeinterval[13..<15])!, Int(timeinterval[15..<17])!).add(86400)
                return TimerangeDt(start: start, to: end, dtSeconds: dt)
            }
            // Cerra has a typical delay of 5 days
            // Per default, check last 14 days for new data. If data is already downloaded, downloading is skipped
            let lastDays = 14
            let time0z = Timestamp.now().with(hour: 0)
            return TimerangeDt(start: time0z.add(lastDays * -86400), to: time0z, dtSeconds: dt)
        }
    }

    var help: String {
        "Download CERRA from the ECMWF climate data store and convert"
    }
    
    func stripSea(logger: Logger, readFilePath: String, writeFilePath: String, elevation: [Float]) throws {
        let domain = CdsDomain.cerra
        if FileManager.default.fileExists(atPath: writeFilePath) {
            return
        }
        let read = try OmFileReader(file: readFilePath)
        
        var percent = 0
        try OmFileWriter(dim0: read.dim0, dim1: read.dim1, chunk0: read.chunk0, chunk1: read.chunk1).write(file: writeFilePath, compressionType: .p4nzdec256, scalefactor: read.scalefactor) { dim0 in
            let ratio = Int(Float(dim0) / (Float(read.dim0)) * 100)
            if percent != ratio {
                logger.info("\(ratio) %")
                percent = ratio
            }
            
            let nLocations = 1000 * read.chunk0
            let locationRange = dim0..<min(dim0+nLocations, read.dim0)
            
            try read.willNeed(dim0Slow: locationRange, dim1: 0..<read.dim1)
            var data = try read.read(dim0Slow: locationRange, dim1: nil)
            for loc in locationRange {
                let (lat,lon) = domain.grid.getCoordinates(gridpoint: loc)
                let isNorthRussia = lon >= 43 && lat > 63
                let isNorthCanadaGreenlandAlaska = lat > 66 && lon < -26
                let isAntarctica = lat < -56
                
                if elevation[loc] <= -999 || lat > 72 || isNorthRussia || isNorthCanadaGreenlandAlaska || isAntarctica {
                    for t in 0..<read.dim1 {
                        data[(loc-dim0) * read.dim1 + t] = .nan
                    }
                }
            }
            return ArraySlice(data)
        }
    }
    
    func runStripSea(logger: Logger, year: Int) throws {
        let domain = CdsDomain.cerra
        try FileManager.default.createDirectory(atPath: "\(OpenMeteo.dataDictionary)cerra-no-sea", withIntermediateDirectories: true)
        logger.info("Read elevation")
        let elevation = try OmFileReader(file: domain.surfaceElevationFileOm).readAll()
        
        for variable in CerraVariable.allCases {
            logger.info("Converting variable \(variable)")
            let fullFile = "\(domain.omfileArchive!)\(variable)_\(year).om"
            let strippedFile = "\(OpenMeteo.dataDictionary)cerra-no-sea/\(variable)_\(year).om"
            try stripSea(logger: logger, readFilePath: fullFile, writeFilePath: strippedFile, elevation: elevation)
        }
    }
    
    func runYear(logger: Logger, year: Int, cdskey: String) throws {
        let domain = CdsDomain.cerra
        let timeinterval = TimerangeDt(start: Timestamp(year,1,1), to: Timestamp(year+1,1,1), dtSeconds: 24*3600)
        let _ = try downloadDailyFilesCerra(logger: logger, cdskey: cdskey, timeinterval: timeinterval)
        
        let nx = domain.grid.nx // 721
        let ny = domain.grid.ny // 1440
        let nt = timeinterval.count * 24 // 8784
        
        let variables = CerraVariable.allCases
        
        // convert to yearly file
        for variable in variables {
            logger.info("Converting variable \(variable)")
            let writeFile = "\(domain.omfileArchive!)\(variable)_\(year).om"
            if FileManager.default.fileExists(atPath: writeFile) {
                continue
            }
            let omFiles = try timeinterval.map { timeinterval -> OmFileReader in
                let timestampDir = "\(domain.downloadDirectory)\(timeinterval.format_YYYYMMdd)"
                let omFile = "\(timestampDir)/\(variable.rawValue)_\(timeinterval.format_YYYYMMdd).om"
                return try OmFileReader(file: omFile)
            }
            var percent = 0
            var looptime = DispatchTime.now()
            try OmFileWriter(dim0: ny*nx, dim1: nt, chunk0: 6, chunk1: nt/8).write(file: writeFile, compressionType: .p4nzdec256, scalefactor: variable.scalefactor) { dim0 in
                let ratio = Int(Float(dim0) / (Float(nx*ny)) * 100)
                if percent != ratio {
                    /// time ~4.5 seconds
                    logger.info("\(ratio) %, time per step \(looptime.timeElapsedPretty())")
                    looptime = DispatchTime.now()
                    percent = ratio
                }
                
                /// Process around 20 MB memory at once
                let nLoc = 6 * 100
                let locationRange = dim0..<min(dim0+nLoc, nx*ny)
                
                var fasttime = Array2DFastTime(data: [Float](repeating: .nan, count: nt * locationRange.count), nLocations: locationRange.count, nTime: nt)
                
                for (i, omfile) in omFiles.enumerated() {
                    try omfile.willNeed(dim0Slow: locationRange, dim1: 0..<24)
                    let read = try omfile.read(dim0Slow: locationRange, dim1: 0..<24)
                    let read2d = Array2DFastTime(data: read, nLocations: locationRange.count, nTime: 24)
                    for l in 0..<locationRange.count {
                        fasttime[l, i*24 ..< (i+1)*24] = read2d[l, 0..<24]
                    }
                }
                return ArraySlice(fasttime.data)
            }
        }
    }
    
    /// Download ERA5 files from CDS and convert them to daily compressed files
    func downloadDailyFilesCerra(logger: Logger, cdskey: String, timeinterval: TimerangeDt) throws {
        let domain = CdsDomain.cerra
        logger.info("Downloading timerange \(timeinterval.prettyString())")
        
        /// Directory dir, where to place temporary downloaded files
        let downloadDir = domain.downloadDirectory
        try FileManager.default.createDirectory(atPath: downloadDir, withIntermediateDirectories: true)
                
        let variables = CerraVariable.allCases
        
        /// loop over each day, download data and convert it
        let pid = 98495 //ProcessInfo.processInfo.processIdentifier
        let tempDownloadGribFile = "\(downloadDir)cerradownload_\(pid).grib"
        let tempPythonFile = "\(downloadDir)cerradownload_\(pid).py"
        
        /// The effective range of downloaded steps
        /// The lower bound will be adapted if timesteps already exist
        /// The upper bound will be reduced if the files are not yet on the remote server
        var downloadedRange = timeinterval.range.upperBound ..< timeinterval.range.upperBound
        
        var grib2d = GribArray2D(nx: domain.grid.nx, ny: domain.grid.ny)
        
        /// Number of timestamps per file
        let nt = timeinterval.dtSeconds == 3600 ? 1 : 24
        let writer = OmFileWriter(dim0: 1, dim1: domain.grid.count, chunk0: 1, chunk1: 600)
        
        timeLoop: for timestamp in timeinterval {
            logger.info("Downloading timestamp \(timestamp.format_YYYYMMdd)")
            let date = timestamp.toComponents()
            let timestampDir = "\(domain.downloadDirectory)\(timestamp.format_YYYYMMdd)"
            
            if FileManager.default.fileExists(atPath: "\(timestampDir)/\(variables[0].rawValue)_\(timestamp.format_YYYYMMdd)00.om") {
                continue
            }
            
            let ncvariables = variables.map { $0.cdsApiName }
            let variablesEncoded = String(data: try JSONEncoder().encode(ncvariables), encoding: .utf8)!
            
            // download analysis
            let pyCode = """
                import cdsapi

                c = cdsapi.Client(url="https://cds.climate.copernicus.eu/api/v2", key="\(cdskey)", verify=True)
                try:
                    c.retrieve(
                        '\(domain.cdsDatasetName)',
                        {
                            'product_type': 'analysis',
                            'format': 'grib',
                            'variable': \(variablesEncoded),
                            'level_type': 'surface_or_atmosphere',
                            'data_type': 'reanalysis',
                            'year': '\(date.year)',
                            'month': '\(date.month.zeroPadded(len: 2))',
                            'day': '\(date.day.zeroPadded(len: 2))',
                            'time': ['00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00',],
                        },
                        '\(tempDownloadGribFile)')
                except Exception as e:
                    if "Please, check that your date selection is valid" in str(e):
                        exit(70)
                    if "the request you have submitted is not valid" in str(e):
                        exit(70)
                    raise e
                """
            
            try pyCode.write(toFile: tempPythonFile, atomically: true, encoding: .utf8)
            do {
                try Process.spawn(cmd: "python3", args: [tempPythonFile])
            } catch SpawnError.commandFailed(cmd: let cmd, returnCode: let code, args: let args) {
                if code == 70 {
                    logger.info("Timestep \(timestamp.iso8601_YYYY_MM_dd) seems to be unavailable. Skipping downloading now.")
                    downloadedRange = min(downloadedRange.lowerBound, timestamp) ..< timestamp
                    break timeLoop
                } else {
                    throw SpawnError.commandFailed(cmd: cmd, returnCode: code, args: args)
                }
            }
            try FileManager.default.createDirectory(atPath: timestampDir, withIntermediateDirectories: true)
            
            var i = 0
            try SwiftEccodes.iterateMessages(fileName: tempDownloadGribFile, multiSupport: true) { message in
                let variable = variables[i % variables.count]
                i += 1
                
                /// (key: "validityTime", value: "1700")
                let hour = Int(message.get(attribute: "validityTime")!)!/100
                logger.info("Converting variable \(variable) hour \(hour)")
                //try message.debugGrid(grid: domain.grid)
                
                try grib2d.load(message: message)
                let scaling = variable.netCdfScaling
                grib2d.array.data.multiplyAdd(multiply: Float(scaling.scalefactor), add: Float(scaling.offest))
                
                let omFile = "\(timestampDir)/\(variable.rawValue)_\(timestamp.format_YYYYMMdd)\(hour.zeroPadded(len: 2)).om"
                try FileManager.default.removeItemIfExists(at: omFile)
                try writer.write(file: omFile, compressionType: .p4nzdec256, scalefactor: variable.scalefactor, all: grib2d.array.data)
            }
            
            // download forecast
            let pyCode2 = """
                import cdsapi

                c = cdsapi.Client(url="https://cds.climate.copernicus.eu/api/v2", key="\(cdskey)", verify=True)
                try:
                    c.retrieve(
                        '\(domain.cdsDatasetName)',
                        {
                            'product_type': 'forecast',
                            'format': 'grib',
                            'variable': \(variablesEncoded),
                            'level_type': 'surface_or_atmosphere',
                            'data_type': 'reanalysis',
                            'year': '\(date.year)',
                            'month': '\(date.month.zeroPadded(len: 2))',
                            'day': '\(date.day.zeroPadded(len: 2))',
                            'leadtime_hour': ['1', '2'],
                            'time': ['00:00', '03:00', '06:00', '09:00', '12:00', '15:00', '18:00', '21:00',],
                        },
                        '\(tempDownloadGribFile)')
                except Exception as e:
                    if "Please, check that your date selection is valid" in str(e):
                        exit(70)
                    if "the request you have submitted is not valid" in str(e):
                        exit(70)
                    raise e
                """
            
            try pyCode2.write(toFile: tempPythonFile, atomically: true, encoding: .utf8)
            do {
                try Process.spawn(cmd: "python3", args: [tempPythonFile])
            } catch SpawnError.commandFailed(cmd: let cmd, returnCode: let code, args: let args) {
                if code == 70 {
                    logger.info("Timestep \(timestamp.iso8601_YYYY_MM_dd) seems to be unavailable. Skipping downloading now.")
                    downloadedRange = min(downloadedRange.lowerBound, timestamp) ..< timestamp
                    break timeLoop
                } else {
                    throw SpawnError.commandFailed(cmd: cmd, returnCode: code, args: args)
                }
            }
            try FileManager.default.createDirectory(atPath: timestampDir, withIntermediateDirectories: true)
            
            i = 0
            try SwiftEccodes.iterateMessages(fileName: tempDownloadGribFile, multiSupport: true) { message in
                let variable = variables[i % variables.count]
                i += 1
                
                /// (key: "validityTime", value: "1700")
                let hour = Int(message.get(attribute: "validityTime")!)!/100
                logger.info("Converting variable \(variable) hour \(hour)")
                //try message.debugGrid(grid: domain.grid)
                
                try grib2d.load(message: message)
                let scaling = variable.netCdfScaling
                grib2d.array.data.multiplyAdd(multiply: Float(scaling.scalefactor), add: Float(scaling.offest))
                
                let omFile = "\(timestampDir)/\(variable.rawValue)_\(timestamp.format_YYYYMMdd)\(hour.zeroPadded(len: 2)).om"
                try FileManager.default.removeItemIfExists(at: omFile)
                try writer.write(file: omFile, compressionType: .p4nzdec256, scalefactor: variable.scalefactor, all: grib2d.array.data)
            }
            
            
            fatalError()
        }
        
        
        try FileManager.default.removeItemIfExists(at: tempDownloadGribFile)
        try FileManager.default.removeItemIfExists(at: tempPythonFile)
    }
    
    /// Convert daily compressed files to longer compressed files specified by `Cerra.omFileLength`. E.g. 14 days in one file.
    func convertDailyFiles(logger: Logger, timeinterval: TimerangeDt) throws {
        let domain = CdsDomain.cerra
        if timeinterval.count == 0 {
            logger.info("No new timesteps could be downloaded. Nothing to do. Existing")
            return
        }
        
        logger.info("Converting timerange \(timeinterval.prettyString())")
       
        /// Directory dir, where to place temporary downloaded files
        let downloadDir = domain.downloadDirectory
        try FileManager.default.createDirectory(atPath: downloadDir, withIntermediateDirectories: true)
        
        let om = OmFileSplitter(basePath: domain.omfileDirectory, nLocations: domain.grid.count, nTimePerFile: domain.omFileLength, yearlyArchivePath: nil)
        
        let variables = CerraVariable.allCases // [CerraVariable.wind_u_component_10m, .wind_v_component_10m, .wind_u_component_100m, .wind_v_component_100m]
        
        let ntPerFile = timeinterval.dtSeconds == 3600 ? 1 : 24
        
        /// loop over each day convert it
        for variable in variables {
            logger.info("Converting variable \(variable)")
            
            let nt = timeinterval.count * ntPerFile
            let nLoc = domain.grid.count
            
            var fasttime = Array2DFastTime(data: [Float](repeating: .nan, count: nt*nLoc), nLocations: nLoc, nTime: nt)
            
            for (i,timestamp) in timeinterval.enumerated() {
                let timestampDailyHourly = timeinterval.dtSeconds == 3600 ? timestamp.format_YYYYMMddHH : timestamp.format_YYYYMMdd
                logger.info("Reading timestamp \(timestampDailyHourly)")
                let timestampDir = "\(domain.downloadDirectory)\(timestamp.format_YYYYMMdd)"
                let omFile =  "\(timestampDir)/\(variable.rawValue)_\(timestampDailyHourly).om"
                
                guard FileManager.default.fileExists(atPath: omFile) else {
                    continue
                }
                let data = try OmFileReader(file: omFile).readAll()
                let read2d = Array2DFastTime(data: data, nLocations: nLoc, nTime: ntPerFile)
                for l in 0..<nLoc {
                    fasttime[l, i*ntPerFile ..< (i+1)*ntPerFile] = read2d[l, 0..<ntPerFile]
                }
            }
            
            logger.info("Writing \(variable)")
            let ringtime = timeinterval.range.lowerBound.timeIntervalSince1970 / 3600 ..< timeinterval.range.upperBound.timeIntervalSince1970 / 3600
            try om.updateFromTimeOriented(variable: variable.rawValue, array2d: fasttime, ringtime: ringtime, skipFirst: 0, smooth: 0, skipLast: 0, scalefactor: variable.scalefactor)
        }
    }
    
    func run(using context: CommandContext, signature: Signature) throws {
        let logger = context.application.logger
        if let stripseaYear = signature.stripseaYear {
            try runStripSea(logger: logger, year: Int(stripseaYear)!)
            return
        }
        guard let cdskey = signature.cdskey else {
            fatalError("cds key is required")
        }
        let domain = CdsDomain.cerra
        try DownloadEra5Command().downloadElevation(logger: logger, cdskey: cdskey, domain: domain)
        
        /// Only download one specified year
        if let yearStr = signature.year {
            guard let year = Int(yearStr) else {
                fatalError("Could not convert year to integer")
            }
            try runYear(logger: logger, year: year, cdskey: cdskey)
            return
        }
        
        /// Select the desired timerange, or use last 14 day
        let timeinterval = signature.getTimeinterval()
        try downloadDailyFilesCerra(logger: logger, cdskey: cdskey, timeinterval: timeinterval)
        try convertDailyFiles(logger: logger, timeinterval: timeinterval)
    }
}

