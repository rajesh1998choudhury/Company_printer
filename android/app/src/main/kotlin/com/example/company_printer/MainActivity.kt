package com.sit.company_printer

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.pdfcreator"
    private val CREATE_FILE_REQUEST_CODE = 1001
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "createDocument" -> {
                    val mimeType = call.argument<String>("mimeType")
                    val filename = call.argument<String>("fileName")
                    if (mimeType != null && filename != null) {
                        createDocument(filename, mimeType, result)
                    } else {
                        result.error("INVALID_ARGS", "Arguments missing", null)
                    }
                }

                "writeBytes" -> {
                    val uriString = call.argument<String>("uri")
                    val bytes = call.argument<List<*>>("bytes")
                    if (uriString != null && bytes != null) {
                        writeBytes(uriString, bytes, result)
                    } else {
                        result.error("INVALID_ARGS", "Arguments missing", null)
                    }
                }

                "openDocument" -> {
                    val uriString = call.argument<String>("uri")
                    if (uriString != null) {
                        openDocument(uriString, result)
                    } else {
                        result.error("INVALID_URI", "URI is null", null)
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun createDocument(filename: String, mimeType: String, result: MethodChannel.Result) {
        pendingResult = result
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, filename)
        }
        startActivityForResult(intent, CREATE_FILE_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == CREATE_FILE_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val uri: Uri? = data.data
                pendingResult?.success(uri?.toString())
            } else {
                pendingResult?.success(null)
            }
        }
    }

    private fun writeBytes(uriString: String, bytes: List<*>, result: MethodChannel.Result) {
        try {
            Log.d("WRITE_BYTES", "Writing to URI: $uriString, Bytes size: ${bytes.size}")
            val byteArray = ByteArray(bytes.size) { i ->
                (bytes[i] as? Int)?.toByte() ?: run {
                    result.error("INVALID_BYTE", "Invalid byte value at index $i", null)
                    return
                }
            }

            if (uriString.startsWith("/")) {
                val file = java.io.File(uriString)
                file.outputStream().use {
                    it.write(byteArray)
                }
                result.success(null)
            } else {
                val uri = Uri.parse(uriString)
                val outputStream = contentResolver.openOutputStream(uri)
                if (outputStream != null) {
                    outputStream.use {
                        it.write(byteArray)
                    }
                    result.success(null)
                } else {
                    result.error("OUTPUT_STREAM_ERROR", "Unable to open output stream", null)
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
            result.error("WRITE_ERROR", e.localizedMessage, null)
        }
    }

    private fun openDocument(uriString: String, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(uriString)
            val intent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(uri, "application/pdf")
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.error("OPEN_ERROR", e.localizedMessage, null)
        }
    }
}

