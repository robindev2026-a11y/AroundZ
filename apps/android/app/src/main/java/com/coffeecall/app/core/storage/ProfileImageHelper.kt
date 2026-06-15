package com.coffeecall.app.core.storage

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import java.io.File
import java.io.FileOutputStream

object ProfileImageHelper {
    private const val FILE_NAME = "profile_photo.jpg"

    fun saveProfileImage(context: Context, bytes: ByteArray) {
        val file = File(context.filesDir, FILE_NAME)
        try {
            FileOutputStream(file).use { out ->
                out.write(bytes)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun saveProfileImage(context: Context, bitmap: Bitmap) {
        val file = File(context.filesDir, FILE_NAME)
        try {
            FileOutputStream(file).use { out ->
                bitmap.compress(Bitmap.CompressFormat.JPEG, 80, out)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    fun loadProfileImage(context: Context): Bitmap? {
        val file = File(context.filesDir, FILE_NAME)
        return if (file.exists()) {
            BitmapFactory.decodeFile(file.absolutePath)
        } else {
            null
        }
    }

    fun loadProfileImageBytes(context: Context): ByteArray? {
        val file = File(context.filesDir, FILE_NAME)
        return if (file.exists()) {
            file.readBytes()
        } else {
            null
        }
    }

    fun loadProfileImageFile(context: Context): File? {
        val file = File(context.filesDir, FILE_NAME)
        return if (file.exists()) file else null
    }

    fun clearProfileImage(context: Context) {
        val file = File(context.filesDir, FILE_NAME)
        if (file.exists()) {
            file.delete()
        }
    }
}
