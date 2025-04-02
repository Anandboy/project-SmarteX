package com.example.personal_expense_tracker

import android.content.Context
import android.database.Cursor
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_retrieval_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, 
            CHANNEL
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getSMSMessages" -> {
                    val limit = call.argument<Int>("limit") ?: -1
                    val messages = getSMSMessages(limit)
                    result.success(messages)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getSMSMessages(limit: Int = -1): List<String> {
        val messages = mutableListOf<String>()
        
        try {
            val uri = Uri.parse("content://sms/inbox")
            val cursor: Cursor? = contentResolver.query(
                uri, 
                arrayOf("body"), 
                null, 
                null, 
                "date DESC"
            )

            cursor?.use {
                val bodyIndex = it.getColumnIndexOrThrow("body")
                var count = 0
                while (it.moveToNext() && (limit == -1 || count < limit)) {
                    messages.add(it.getString(bodyIndex))
                    count++
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return messages
    }
}