package com.example.airawareapp

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.huawei.agconnect.config.AGConnectServicesConfig
import com.huawei.hms.api.ConnectionResult
import com.huawei.hms.api.HuaweiApiAvailability
import com.huawei.hms.location.*

class MainActivity : FlutterActivity() {
    companion object {
        private const val TAG = "MainActivity"
        private const val CHANNEL = "com.example.airawareapp/hms_location"
    }
    
    private var fusedLocationClient: FusedLocationProviderClient? = null
    private var isHMSAvailable = false
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // ✅ Check HMS Core availability
        val huaweiApiAvailability = HuaweiApiAvailability.getInstance()
        val resultCode = huaweiApiAvailability.isHuaweiMobileServicesAvailable(this)
        
        if (resultCode == ConnectionResult.SUCCESS) {
            isHMSAvailable = true
            Log.i(TAG, "✅ HMS Core is available - will use HMS Location")
            
            // ✅ Initialize Huawei AGConnect
            try {
                AGConnectServicesConfig.fromContext(this)
                Log.i(TAG, "✅ AGConnect initialized successfully")
                
                // Initialize HMS Location
                fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
                Log.i(TAG, "✅ HMS Location client initialized")
            } catch (e: Exception) {
                Log.e(TAG, "❌ HMS initialization failed: ${e.message}")
                isHMSAvailable = false
            }
        } else {
            isHMSAvailable = false
            Log.w(TAG, "⚠️ HMS Core not available (code: $resultCode). Will use standard Android GPS.")
        }
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isHMSAvailable" -> {
                    result.success(isHMSAvailable)
                }
                "getHMSLocation" -> {
                    if (isHMSAvailable && fusedLocationClient != null) {
                        getHMSLocation(result)
                    } else {
                        result.error("HMS_NOT_AVAILABLE", "HMS Location is not available", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    private fun getHMSLocation(result: MethodChannel.Result) {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) 
            != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "Location permission not granted", null)
            return
        }
        
        val resultSent = java.util.concurrent.atomic.AtomicBoolean(false)
        
        try {
            // ALWAYS request fresh location for accurate weather data
            // Don't use cached location as it might be old and inaccurate
            Log.i(TAG, "🔍 Requesting fresh location for accurate weather...")
            requestFreshLocation(result, resultSent)
            
            // Timeout after 15 seconds
            android.os.Handler(Looper.getMainLooper()).postDelayed({
                if (resultSent.compareAndSet(false, true)) {
                    Log.w(TAG, "⏱️ HMS Location timeout - no location received in 15 seconds")
                    result.error("TIMEOUT", "HMS Location request timed out", null)
                }
            }, 15000)
            
        } catch (e: Exception) {
            if (resultSent.compareAndSet(false, true)) {
                Log.e(TAG, "❌ HMS Location error: ${e.message}")
                result.error("HMS_ERROR", e.message, null)
            }
        }
    }
    
    private fun requestFreshLocation(result: MethodChannel.Result, resultSent: java.util.concurrent.atomic.AtomicBoolean) {
        try {
            // Use HIGH_ACCURACY for most accurate GPS location
            val locationRequest = LocationRequest.create().apply {
                priority = LocationRequest.PRIORITY_HIGH_ACCURACY // GPS only for best accuracy
                interval = 1000
                fastestInterval = 500
                numUpdates = 1
            }
            
            val locationCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    val location = locationResult.lastLocation
                    if (location != null && resultSent.compareAndSet(false, true)) {
                        Log.i(TAG, "✅ HMS FRESH Location obtained: ${location.latitude}, ${location.longitude} (accuracy: ${location.accuracy}m)")
                        val locationMap = hashMapOf(
                            "latitude" to location.latitude,
                            "longitude" to location.longitude,
                            "accuracy" to location.accuracy.toDouble(),
                            "timestamp" to location.time
                        )
                        result.success(locationMap)
                    }
                    fusedLocationClient?.removeLocationUpdates(this)
                }
                
                override fun onLocationAvailability(availability: LocationAvailability) {
                    if (!availability.isLocationAvailable && resultSent.compareAndSet(false, true)) {
                        Log.w(TAG, "⚠️ HMS Location not available (status 1001) - trying network location")
                        // Try network-based location as last resort
                        tryNetworkLocation(result, resultSent)
                        fusedLocationClient?.removeLocationUpdates(this)
                    }
                }
            }
            
            Log.i(TAG, "🔍 Requesting HMS FRESH HIGH ACCURACY location (GPS)...")
            fusedLocationClient?.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
            )
            
        } catch (e: Exception) {
            if (resultSent.compareAndSet(false, true)) {
                Log.e(TAG, "❌ HMS location request error: ${e.message}")
                result.error("HMS_ERROR", e.message, null)
            }
        }
    }
    
    private fun tryNetworkLocation(result: MethodChannel.Result, resultSent: java.util.concurrent.atomic.AtomicBoolean) {
        if (resultSent.get()) return
        
        try {
            val networkRequest = LocationRequest.create().apply {
                priority = LocationRequest.PRIORITY_LOW_POWER
                interval = 1000
                numUpdates = 1
            }
            
            val networkCallback = object : LocationCallback() {
                override fun onLocationResult(locationResult: LocationResult) {
                    val location = locationResult.lastLocation
                    if (location != null && resultSent.compareAndSet(false, true)) {
                        Log.i(TAG, "✅ HMS Network location obtained: ${location.latitude}, ${location.longitude}")
                        val locationMap = hashMapOf(
                            "latitude" to location.latitude,
                            "longitude" to location.longitude,
                            "accuracy" to location.accuracy.toDouble(),
                            "timestamp" to location.time
                        )
                        result.success(locationMap)
                    }
                    fusedLocationClient?.removeLocationUpdates(this)
                }
            }
            
            Log.i(TAG, "� Trying HMS network-based location...")
            fusedLocationClient?.requestLocationUpdates(
                networkRequest,
                networkCallback,
                Looper.getMainLooper()
            )
        } catch (e: Exception) {
            if (resultSent.compareAndSet(false, true)) {
                Log.e(TAG, "❌ Network location error: ${e.message}")
                result.error("LOCATION_UNAVAILABLE", "HMS Location not available", null)
            }
        }
    }
}
