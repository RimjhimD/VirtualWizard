package com.example.virtualwizard.ui.screens

import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.virtualwizard.R
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.json.JSONArray
import java.io.BufferedInputStream
import java.net.URL
import javax.net.ssl.HttpsURLConnection

@Composable
fun LoadingScreen(onNavigateToMenu: () -> Unit) {
    val coroutineScope = rememberCoroutineScope()

    // Animation for the "Loading" text
    val infiniteTransition = rememberInfiniteTransition()
    val alpha by infiniteTransition.animateFloat(
        initialValue = 0.5f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(durationMillis = 1000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        )
    )

    // Loading task states
    var quote by remember { mutableStateOf("Fetching quote...") }
    var isAssetsLoaded by remember { mutableStateOf(false) }
    var isFirebaseInitialized by remember { mutableStateOf(false) }
    var loadingComplete by remember { mutableStateOf(false) }

    // Perform all loading tasks
    LaunchedEffect(Unit) {
        coroutineScope.launch {
            quote = fetchRandomQuote() // Fetch a random quote
        }
        coroutineScope.launch {
            delay(2000) // Simulate loading assets
            isAssetsLoaded = true
        }
        coroutineScope.launch {
            delay(1500) // Simulate Firebase initialization
            isFirebaseInitialized = true
        }
    }

    // Check if all tasks are complete
    LaunchedEffect(isAssetsLoaded, isFirebaseInitialized, quote) {
        if (isAssetsLoaded && isFirebaseInitialized && quote != "Fetching quote...") {
            loadingComplete = true
        }
    }

    // Layout
    Box(
        modifier = Modifier
            .fillMaxSize()
            .clickable(enabled = loadingComplete) { onNavigateToMenu() },
        contentAlignment = Alignment.BottomCenter
    ) {
        // Background image
        Image(
            painter = painterResource(id = R.drawable.placeholder_bg),
            contentDescription = "Loading Screen Background",
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Bottom
        ) {
            // Line 1: Loading text with breathing effect
            if (!loadingComplete) {
                Text(
                    text = "Loading...",
                    fontSize = 24.sp,
                    color = Color.White.copy(alpha = alpha),
                    textAlign = TextAlign.Center
                )
            }

            // Line 2: Random quote fetched from API
            Text(
                text = quote,
                fontSize = 16.sp,
                color = Color.Gray,
                textAlign = TextAlign.Center,
                modifier = Modifier.padding(top = 8.dp)
            )

            // Line 3: Click to continue (hidden until loading is complete)
            if (loadingComplete) {
                Text(
                    text = "Click anywhere to continue",
                    fontSize = 20.sp,
                    color = Color.White,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.padding(top = 8.dp)
                )
            }
        }
    }
}

// Function to fetch a random quote using ZenQuotes API
suspend fun fetchRandomQuote(): String {
    return withContext(Dispatchers.IO) {
        try {
            val url = URL("https://zenquotes.io/api/random")
            val connection = url.openConnection() as HttpsURLConnection
            connection.requestMethod = "GET"
            connection.connectTimeout = 5000
            connection.readTimeout = 5000

            if (connection.responseCode == HttpsURLConnection.HTTP_OK) {
                BufferedInputStream(connection.inputStream).bufferedReader().use { reader ->
                    val response = reader.readText()
                    val jsonArray = JSONArray(response)
                    val json = jsonArray.getJSONObject(0)
                    val content = json.getString("q")
                    val author = json.getString("a")
                    "\"$content\" - $author"
                }
            } else {
                "Unable to fetch a quote. Please try again."
            }
        } catch (e: Exception) {
            "Failed to fetch quote: ${e.localizedMessage}"
        }
    }
}
