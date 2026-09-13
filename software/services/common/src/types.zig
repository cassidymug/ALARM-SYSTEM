// Guardian shared types
const std = @import("std");

/// Camera configuration with resolution profile support (Full HD, 4K, 8K)
pub const CameraConfig = struct {
    id: []const u8,
    name: []const u8,
    rtsp_url: []const u8,
    rtsp_substream_url: ?[]const u8 = null,
    
    /// Maximum resolution profile for this camera
    max_resolution: ResolutionProfile = .full_hd,
    
    /// Whether this camera has audio
    audio_enabled: bool = true,
    
    /// Whether to enable motion detection
    detect_enabled: bool = true,
    
    /// Whether this is an intercom station (gate/door)
    intercom_enabled: bool = false,
    
    /// Advanced detection capabilities for this camera
    detection_capabilities: DetectionCapabilities = .{},
    
    /// Camera location/zone for filtering
    location: []const u8 = "default",
};

/// Resolution profiles for recording and live view
pub const ResolutionProfile = enum {
    /// 1920x1080 (Full HD)
    full_hd,
    /// 3840x2160 (4K UHD)
    uhd_4k,
    /// 7680x4320 (8K UHD)
    uhd_8k,
    
    pub fn getWidth(self: ResolutionProfile) u32 {
        return switch (self) {
            .full_hd => 1920,
            .uhd_4k => 3840,
            .uhd_8k => 7680,
        };
    }
    
    pub fn getHeight(self: ResolutionProfile) u32 {
        return switch (self) {
            .full_hd => 1080,
            .uhd_4k => 2160,
            .uhd_8k => 4320,
        };
    }
    
    pub fn getEstimatedBitrateMbps(self: ResolutionProfile) u32 {
        return switch (self) {
            .full_hd => 4,
            .uhd_4k => 25,
            .uhd_8k => 100,
        };
    }
};

/// Sensor zone configuration
pub const ZoneConfig = struct {
    id: []const u8,
    name: []const u8,
    zone_type: ZoneType,
    sensor_type: SensorType,
    sensor_bindings: []const []const u8,
    bypass_enabled: bool = false,
    chime_enabled: bool = false,
    entry_delay_ms: ?u64 = null,
    
    /// Thresholds for analog sensors
    thresholds: ?SensorThresholds = null,
    
    /// Actions to take on sensor events
    actions: ?SensorActions = null,
};

pub const ZoneType = enum {
    perimeter,
    interior,
    @"24h",
    fire,
    panic,
};

/// Sensor type definitions
pub const SensorType = enum {
    /// Contact sensors
    door_window,      // Standard contact sensor
    glass_break,      // Acoustic glass break detector
    panic_button,     // Manual panic/duress button
    tamper,          // Tamper switch
    
    /// Motion sensors
    pir_motion,      // Passive infrared motion detector
    dual_tech,       // PIR + microwave
    
    /// Life safety
    smoke_detector,       // Smoke/fire detector
    heat_detector,        // Fixed/rate-of-rise heat
    co_detector,          // Carbon monoxide
    gas_detector,         // Natural gas/propane
    water_leak,           // Water leak detector
    
    /// Environmental
    temperature,          // Temperature sensor
    humidity,             // Humidity sensor
    freeze,              // Freeze sensor (pipes)
    
    /// Perimeter
    beam_sensor,         // Photoelectric beam
    vibration,           // Vibration/shock sensor
    metal_detector,      // Walk-through metal detector
    
    /// Custom
    analog_custom,       // Custom analog sensor
    digital_custom,      // Custom digital sensor
};

/// Sensor thresholds for analog sensors
pub const SensorThresholds = struct {
    warning: ?f32 = null,
    critical: ?f32 = null,
    shutdown: ?f32 = null,
    
    /// For multi-level sensors (CO, gas)
    danger: ?f32 = null,
    extreme: ?f32 = null,
};

/// Actions to perform on sensor events
pub const SensorActions = struct {
    on_warning: []const Action = &.{},
    on_critical: []const Action = &.{},
    on_alarm: []const Action = &.{},
};

pub const Action = enum {
    notify,
    alarm,
    call_fire_dept,
    call_police,
    snapshot_camera,
    start_recording,
    activate_siren,
    activate_strobe,
    unlock_doors,
    shut_down_hvac,
    turn_on_lights,
    evacuate,
};

/// Alarm system state
pub const AlarmState = enum {
    disarmed,
    exit_delay,
    armed_away,
    armed_stay,
    entry_delay,
    alarm,
};

/// Alarm arming mode
pub const ArmingMode = enum {
    disarmed,
    armed_away,
    armed_stay,
};

/// Backup scope options
pub const BackupScope = enum {
    events_only,
    events_plus_rolling,
    full_continuous,
};

/// Site configuration
pub const SiteConfig = struct {
    site_name: []const u8,
    cameras: []const CameraConfig,
    zones: []const ZoneConfig,
    backup_scope: BackupScope,
    backup_retention_days: u32,
    backup_bandwidth_cap_mbps: u32,
    relay_url: []const u8,
    storage: StorageConfig = .{},
};

/// Storage configuration for large HDDs/SSDs
pub const StorageConfig = struct {
    /// Base path for recordings (e.g., /srv/guardian/recordings)
    recordings_path: []const u8 = "/srv/guardian/recordings",
    
    /// Maximum storage to use in GB (0 = unlimited)
    max_storage_gb: u64 = 0,
    
    /// Minimum free space to maintain in GB
    min_free_space_gb: u64 = 100,
    
    /// Start cleanup when free space drops below this (GB)
    cleanup_threshold_gb: u64 = 150,
    
    /// Retention policy
    retention: RetentionPolicy = .{},
    
    /// Enable storage monitoring
    monitoring_enabled: bool = true,
    
    /// Alert when free space drops below percentage
    alert_free_space_percent: u8 = 10,
};

/// Retention policy for recordings
pub const RetentionPolicy = struct {
    /// Continuous recording retention in days
    continuous_days: u32 = 30,
    
    /// Event-triggered recording retention in days
    events_days: u32 = 90,
    
    /// Important/flagged recording retention in days
    important_days: u32 = 365,
    
    /// Cleanup priority order
    cleanup_priority: [3]RecordingType = .{ .continuous, .events, .important },
};

/// Recording type for retention priority
pub const RecordingType = enum {
    continuous,
    events,
    important,
};

/// Storage statistics
pub const StorageStats = struct {
    total_bytes: u64,
    used_bytes: u64,
    free_bytes: u64,
    recordings_bytes: u64,
    recording_count: u64,
    write_speed_mbps: f32,
    health_status: StorageHealth,
};

/// Storage health status
pub const StorageHealth = enum {
    healthy,
    warning,
    critical,
    unknown,
};

/// Advanced detection capabilities
pub const DetectionCapabilities = struct {
    /// Facial recognition enabled
    facial_recognition: bool = false,
    /// Number plate recognition enabled
    plate_recognition: bool = false,
    /// Vehicle recognition (make/model/color)
    vehicle_recognition: bool = false,
    /// Gait recognition (person identification by walk)
    gait_recognition: bool = false,
    /// Pet detection (cats, dogs, etc.)
    pet_detection: bool = false,
    /// General motion detection
    motion_detection: bool = true,
    /// Audio event detection
    audio_detection: bool = false,
};

/// Detection event types
pub const DetectionEvent = struct {
    id: []const u8,
    camera_id: []const u8,
    timestamp_ms: u64,
    event_type: DetectionType,
    confidence: f32,
    metadata: DetectionMetadata,
    thumbnail_path: ?[]const u8 = null,
    clip_path: ?[]const u8 = null,
};

pub const DetectionType = enum {
    motion,
    person,
    face_recognized,
    face_unknown,
    vehicle,
    license_plate,
    pet,
    audio_event,
    gait_match,
};

pub const DetectionMetadata = union(enum) {
    motion: MotionMetadata,
    face: FaceMetadata,
    vehicle: VehicleMetadata,
    plate: PlateMetadata,
    pet: PetMetadata,
    gait: GaitMetadata,
    audio: AudioMetadata,
};

pub const MotionMetadata = struct {
    area_percent: f32,
    intensity: f32,
};

pub const FaceMetadata = struct {
    person_id: ?[]const u8,
    person_name: ?[]const u8,
    bbox_x: u32,
    bbox_y: u32,
    bbox_w: u32,
    bbox_h: u32,
};

pub const VehicleMetadata = struct {
    vehicle_type: []const u8, // car, truck, motorcycle, etc.
    make: ?[]const u8,
    model: ?[]const u8,
    color: ?[]const u8,
    bbox_x: u32,
    bbox_y: u32,
    bbox_w: u32,
    bbox_h: u32,
};

pub const PlateMetadata = struct {
    plate_number: []const u8,
    region: ?[]const u8,
    bbox_x: u32,
    bbox_y: u32,
    bbox_w: u32,
    bbox_h: u32,
};

pub const PetMetadata = struct {
    pet_type: []const u8, // dog, cat, etc.
    breed: ?[]const u8,
    bbox_x: u32,
    bbox_y: u32,
    bbox_w: u32,
    bbox_h: u32,
};

pub const GaitMetadata = struct {
    person_id: ?[]const u8,
    person_name: ?[]const u8,
    gait_signature: []const u8,
};

pub const AudioMetadata = struct {
    audio_type: []const u8, // doorbell, glass_break, scream, etc.
    duration_ms: u64,
};

test "resolution profile dimensions" {
    try std.testing.expectEqual(@as(u32, 1920), ResolutionProfile.full_hd.getWidth());
    try std.testing.expectEqual(@as(u32, 1080), ResolutionProfile.full_hd.getHeight());
    try std.testing.expectEqual(@as(u32, 3840), ResolutionProfile.uhd_4k.getWidth());
    try std.testing.expectEqual(@as(u32, 2160), ResolutionProfile.uhd_4k.getHeight());
    try std.testing.expectEqual(@as(u32, 7680), ResolutionProfile.uhd_8k.getWidth());
    try std.testing.expectEqual(@as(u32, 4320), ResolutionProfile.uhd_8k.getHeight());
}

test "resolution profile bitrate estimates" {
    try std.testing.expectEqual(@as(u32, 4), ResolutionProfile.full_hd.getEstimatedBitrateMbps());
    try std.testing.expectEqual(@as(u32, 25), ResolutionProfile.uhd_4k.getEstimatedBitrateMbps());
    try std.testing.expectEqual(@as(u32, 100), ResolutionProfile.uhd_8k.getEstimatedBitrateMbps());
}
