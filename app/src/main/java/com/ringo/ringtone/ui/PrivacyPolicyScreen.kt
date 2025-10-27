package com.ringo.ringtone.ui

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun PrivacyPolicyScreen() {
    val scrollState = rememberScrollState()
    
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
            .verticalScroll(scrollState)
    ) {
        Text(
            "Privacy Policy",
            style = androidx.compose.material3.MaterialTheme.typography.headlineMedium
        )
        
        Text(
            "\nLast updated: October 26, 2025\n",
            style = androidx.compose.material3.MaterialTheme.typography.bodyMedium
        )
        
        Text(
            "\n1. Information We Collect\n" +
            "\n" +
            "We collect information you provide directly to us when using our app, including:\n" +
            "- Your preferences and settings\n" +
            "- Usage data to improve our services\n" +
            "\n" +
            "We also collect information automatically, such as:\n" +
            "- Device information\n" +
            "- Log information\n" +
            "- Usage statistics\n",
            style = androidx.compose.material3.MaterialTheme.typography.bodyMedium
        )
        
        Text(
            "\n2. How We Use Information\n" +
            "\n" +
            "We use the information we collect to:\n" +
            "- Provide, maintain, and improve our services\n" +
            "- Personalize your experience\n" +
            "- Respond to your comments and questions\n" +
            "- Send you technical notices and support messages\n",
            style = androidx.compose.material3.MaterialTheme.typography.bodyMedium
        )
        
        Text(
            "\n3. Information Sharing\n" +
            "\n" +
            "We do not share your personal information with third parties except:\n" +
            "- With your consent\n" +
            "- For legal compliance\n" +
            "- To protect our rights and property\n",
            style = androidx.compose.material3.MaterialTheme.typography.bodyMedium
        )
        
        Text(
            "\n4. Data Security\n" +
            "\n" +
            "We implement appropriate security measures to protect your information, " +
            "but no method of transmission over the Internet is 100% secure.\n",
            style = androidx.compose.material3.MaterialTheme.typography.bodyMedium
        )
        
        Text(
            "\n5. Children's Privacy\n" +
            "\n" +
            "Our service does not address anyone under the age of 13. We do not " +
            "knowingly collect personal information from children under 13.\n",
            style = androidx.compose.material3.MaterialTheme.typography.bodyMedium
        )
        
        Text(
            "\n6. Changes to This Privacy Policy\n" +
            "\n" +
            "We may update our Privacy Policy from time to time. We will notify you " +
            "of any changes by posting the new Privacy Policy on this page.\n",
            style = androidx.compose.material3.MaterialTheme.typography.bodyMedium
        )
        
        Text(
            "\n7. Contact Us\n" +
            "\n" +
            "If you have any questions about this Privacy Policy, please contact us at:\n" +
            "support@ringo.com\n",
            style = androidx.compose.material3.MaterialTheme.typography.bodyMedium
        )
    }
}