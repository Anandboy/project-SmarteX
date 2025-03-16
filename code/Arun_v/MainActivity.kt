package com.example.personal_expense_tracker  // Change this to match your package name

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.net.Uri
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getSmsMessages") {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) == PackageManager.PERMISSION_GRANTED) {
                    val smsList = fetchSms()
                    result.success(smsList)
                } else {
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_SMS), 1)
                    result.error("PERMISSION_DENIED", "SMS permission not granted", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun fetchSms(): List<Map<String, String>> {
        val smsList = mutableListOf<Map<String, String>>()
        val uri: Uri = Uri.parse("content://sms/inbox")
        val cursor: Cursor? = contentResolver.query(uri, null, null, null, "date DESC")

        cursor?.use {
            val indexBody = it.getColumnIndex("body")
            val indexAddress = it.getColumnIndex("address")

            while (it.moveToNext()) {
                val smsBody = if (indexBody != -1) it.getString(indexBody) else "No content"
                val smsAddress = if (indexAddress != -1) it.getString(indexAddress) else "Unknown sender"

                smsList.add(mapOf("body" to smsBody, "address" to smsAddress))
            }
        }
        return smsList
    }
}
