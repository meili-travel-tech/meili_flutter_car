package com.meili.travel.sample.flutter

import android.app.Application
import java.security.Security
import org.conscrypt.Conscrypt

class SampleApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Security.insertProviderAt(Conscrypt.newProvider(), 1)
    }
}
