package com.i5supreme.app

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val openReleases = findViewById<Button>(R.id.open_releases_button)
        openReleases.setOnClickListener {
            val intent = Intent(
                Intent.ACTION_VIEW,
                Uri.parse("https://github.com/shiroonigami23-ui/i5-supreme/releases")
            )
            startActivity(intent)
        }
    }
}
