package com.coffeecall.app.feature.auth

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp

@Composable
fun AuthScreen(
    uiState: AuthUiState,
    onPhoneChanged: (String) -> Unit,
    onCodeChanged: (String) -> Unit,
    onSendOtp: (Activity) -> Unit,
    onVerifyOtp: () -> Unit
) {
    val activity = LocalContext.current.findActivity()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Welcome to CoffeeCall",
            style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.primary
        )
        Text(
            text = if (uiState.isFirebaseConfigured) {
                "Sign in with your phone number."
            } else {
                "Firebase config is missing, so this debug build uses local mock sign-in."
            },
            modifier = Modifier.padding(top = 8.dp, bottom = 24.dp),
            style = MaterialTheme.typography.bodyMedium
        )

        OutlinedTextField(
            value = uiState.phoneNumber,
            onValueChange = onPhoneChanged,
            modifier = Modifier.fillMaxWidth(),
            label = { Text("Phone number") },
            placeholder = { Text("+917012655068") },
            singleLine = true,
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone),
            enabled = !uiState.isLoading
        )

        if (uiState.verificationSent) {
            OutlinedTextField(
                value = uiState.otpCode,
                onValueChange = onCodeChanged,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 12.dp),
                label = { Text("Verification code") },
                placeholder = { Text("666666") },
                singleLine = true,
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                enabled = !uiState.isLoading
            )
        }

        uiState.errorMessage?.let { message ->
            Text(
                text = message,
                modifier = Modifier.padding(top = 12.dp),
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodyMedium
            )
        }

        Button(
            onClick = {
                if (uiState.verificationSent) {
                    onVerifyOtp()
                } else if (activity != null) {
                    onSendOtp(activity)
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 20.dp),
            enabled = !uiState.isLoading && (activity != null || uiState.verificationSent)
        ) {
            Text(
                text = when {
                    uiState.isLoading -> "Please wait"
                    uiState.verificationSent -> "Verify"
                    else -> "Send code"
                }
            )
        }

        if (uiState.verificationSent) {
            TextButton(
                onClick = {
                    if (activity != null) onSendOtp(activity)
                },
                enabled = !uiState.isLoading && activity != null
            ) {
                Text("Resend code")
            }
        }
    }
}

private tailrec fun Context.findActivity(): Activity? =
    when (this) {
        is Activity -> this
        is ContextWrapper -> baseContext.findActivity()
        else -> null
    }
