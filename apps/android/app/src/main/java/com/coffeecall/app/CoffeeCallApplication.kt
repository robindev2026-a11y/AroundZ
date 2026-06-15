package com.coffeecall.app

import android.app.Application
import com.coffeecall.app.core.firebase.FirebaseInitializer

class CoffeeCallApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        FirebaseInitializer.initialize(this)
    }
}
