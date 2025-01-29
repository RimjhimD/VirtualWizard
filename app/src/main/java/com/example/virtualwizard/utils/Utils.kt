package com.example.virtualwizard.utils

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import org.json.JSONArray
import java.io.BufferedInputStream
import java.net.URL
import javax.net.ssl.HttpsURLConnection

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
