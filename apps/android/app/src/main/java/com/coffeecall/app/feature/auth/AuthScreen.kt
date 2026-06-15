package com.coffeecall.app.feature.auth

import android.app.Activity
import android.content.Context
import android.content.ContextWrapper
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.BasicTextField
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.rounded.ArrowBack
import androidx.compose.material.icons.rounded.ArrowDropDown
import androidx.compose.material.icons.rounded.ChevronRight
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.focus.onFocusChanged
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.coffeecall.app.core.design.*

// MARK: - Country Code Model
private data class CountryCode(
    val id: String,
    val name: String,
    val flag: String,
    val dialCode: String
)

private val CountryList = listOf(
    CountryCode("IN", "India", "🇮🇳", "+91"),
    CountryCode("US", "United States", "🇺🇸", "+1"),
    CountryCode("GB", "United Kingdom", "🇬🇧", "+44"),
    CountryCode("CA", "Canada", "🇨🇦", "+1"),
    CountryCode("AU", "Australia", "🇦🇺", "+61"),
    CountryCode("DE", "Germany", "🇩🇪", "+49"),
    CountryCode("FR", "France", "🇫🇷", "+33"),
    CountryCode("SG", "Singapore", "🇸🇬", "+65"),
    CountryCode("AE", "UAE", "🇦🇪", "+971"),
    CountryCode("JP", "Japan", "🇯🇵", "+81"),
    CountryCode("BR", "Brazil", "🇧🇷", "+55"),
    CountryCode("MX", "Mexico", "🇲🇽", "+52"),
    CountryCode("ZA", "South Africa", "🇿🇦", "+27"),
    CountryCode("NG", "Nigeria", "🇳🇬", "+234"),
    CountryCode("PH", "Philippines", "🇵🇭", "+63")
)

@Composable
fun AuthScreen(
    uiState: AuthUiState,
    onPhoneChanged: (String) -> Unit,
    onCodeChanged: (String) -> Unit,
    onSendOtp: (Activity) -> Unit,
    onVerifyOtp: () -> Unit,
    onBackFromOtp: () -> Unit,
    onBackToOnboarding: () -> Unit
) {
    if (uiState.verificationSent) {
        OtpVerificationView(
            uiState = uiState,
            onCodeChanged = onCodeChanged,
            onVerifyOtp = onVerifyOtp,
            onResendCode = { activity -> onSendOtp(activity) },
            onBack = onBackFromOtp
        )
    } else {
        PhoneEntryView(
            uiState = uiState,
            onPhoneChanged = onPhoneChanged,
            onSendOtp = onSendOtp,
            onBack = onBackToOnboarding
        )
    }
}

// MARK: - Phone Entry View
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun PhoneEntryView(
    uiState: AuthUiState,
    onPhoneChanged: (String) -> Unit,
    onSendOtp: (Activity) -> Unit,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    val activity = context.findActivity()

    var localNumber by remember { mutableStateOf("") }
    var selectedCountry by remember { mutableStateOf(CountryList.first()) }
    var showCountryPicker by remember { mutableStateOf(false) }

    // Sync VM number back if initialized externally
    LaunchedEffect(uiState.phoneNumber) {
        val vmPhone = uiState.phoneNumber
        if (vmPhone.isNotEmpty() && localNumber.isEmpty()) {
            val matched = CountryList.firstOrNull { vmPhone.startsWith(it.dialCode) }
            if (matched != null) {
                selectedCountry = matched
                localNumber = vmPhone.substring(matched.dialCode.length)
            } else {
                localNumber = vmPhone
            }
        }
    }

    val isPhoneValid = localNumber.length in 7..15

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = 24.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.Start
        ) {
            // Back button
            Box(
                modifier = Modifier
                    .padding(top = 24.dp, bottom = 24.dp)
                    .size(48.dp)
                    .shadow(
                        elevation = 8.dp,
                        shape = CircleShape,
                        ambientColor = Color.Black.copy(alpha = 0.04f),
                        spotColor = Color.Black.copy(alpha = 0.04f)
                    )
                    .clip(CircleShape)
                    .background(CoffeeSurface)
                    .border(1.dp, CoffeeBorder, CircleShape)
                    .clickable(onClick = onBack),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Rounded.ArrowBack,
                    contentDescription = "Back",
                    tint = CoffeeInk,
                    modifier = Modifier.size(20.dp)
                )
            }

            Text(
                text = "What's your number?",
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Black,
                color = CoffeeInk,
                modifier = Modifier.padding(bottom = 12.dp)
            )

            Text(
                text = "We'll send you a verification code to keep your account secure.",
                style = MaterialTheme.typography.bodyLarge,
                color = CoffeeMuted,
                lineHeight = 22.sp,
                modifier = Modifier.padding(bottom = 36.dp)
            )

            // Input fields
            Text(
                text = "PHONE NUMBER",
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.Black,
                color = CoffeeMuted,
                letterSpacing = 1.0.sp,
                modifier = Modifier.padding(bottom = 8.dp, start = 4.dp)
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Country Code Selector
                Box(
                    modifier = Modifier
                        .height(56.dp)
                        .width(110.dp)
                        .shadow(
                            elevation = 8.dp,
                            shape = RoundedCornerShape(16.dp),
                            ambientColor = Color.Black.copy(alpha = 0.04f),
                            spotColor = Color.Black.copy(alpha = 0.04f)
                        )
                        .clip(RoundedCornerShape(16.dp))
                        .background(CoffeeSurface)
                        .border(1.dp, CoffeeBorder, RoundedCornerShape(16.dp))
                        .clickable { showCountryPicker = true }
                        .padding(horizontal = 12.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        Text(text = selectedCountry.flag, fontSize = 20.sp)
                        Text(
                            text = selectedCountry.dialCode,
                            style = MaterialTheme.typography.bodyLarge,
                            fontWeight = FontWeight.Bold,
                            color = CoffeeInk
                        )
                        Icon(
                            imageVector = Icons.Rounded.ArrowDropDown,
                            contentDescription = null,
                            tint = CoffeeMuted,
                            modifier = Modifier.size(20.dp)
                        )
                    }
                }

                // Phone number textfield
                OutlinedTextField(
                    value = localNumber,
                    onValueChange = { newValue ->
                        val clean = newValue.filter { it.isDigit() }
                        localNumber = clean
                        onPhoneChanged(selectedCountry.dialCode + clean)
                    },
                    modifier = Modifier
                        .weight(1f)
                        .height(56.dp)
                        .shadow(
                            elevation = 8.dp,
                            shape = RoundedCornerShape(16.dp),
                            ambientColor = Color.Black.copy(alpha = 0.04f),
                            spotColor = Color.Black.copy(alpha = 0.04f)
                        )
                        .background(CoffeeSurface, RoundedCornerShape(16.dp)),
                    placeholder = { Text("(555) 000-0000", color = CoffeeMuted) },
                    singleLine = true,
                    enabled = !uiState.isLoading,
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = CoffeeInk,
                        unfocusedTextColor = CoffeeInk,
                        focusedBorderColor = CoffeePrimary,
                        unfocusedBorderColor = Color.Transparent,
                        disabledBorderColor = Color.Transparent
                    ),
                    shape = RoundedCornerShape(16.dp)
                )
            }

            // Error message
            uiState.errorMessage?.let { error ->
                Text(
                    text = error,
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeError,
                    modifier = Modifier.padding(top = 12.dp, start = 4.dp)
                )
            }

            Text(
                text = "Standard SMS rates may apply. You'll receive a 6-digit code to verify your phone.",
                style = MaterialTheme.typography.labelMedium,
                color = CoffeeMuted.copy(alpha = 0.8f),
                lineHeight = 16.sp,
                modifier = Modifier.padding(top = 16.dp, start = 4.dp)
            )

            Spacer(modifier = Modifier.weight(1f))

            // CTA Button
            Button(
                onClick = {
                    if (activity != null) {
                        onSendOtp(activity)
                    }
                },
                enabled = isPhoneValid && !uiState.isLoading && activity != null,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(60.dp)
                    .shadow(
                        elevation = if (isPhoneValid) 12.dp else 0.dp,
                        shape = RoundedCornerShape(16.dp),
                        ambientColor = CoffeePrimary.copy(alpha = 0.22f),
                        spotColor = CoffeePrimary.copy(alpha = 0.22f)
                    ),
                colors = ButtonDefaults.buttonColors(
                    containerColor = CoffeePrimary,
                    contentColor = Color.White,
                    disabledContainerColor = CoffeeMuted.copy(alpha = 0.24f),
                    disabledContentColor = CoffeeMuted
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                if (uiState.isLoading) {
                    CircularProgressIndicator(
                        color = Color.White,
                        modifier = Modifier.size(24.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Text(
                        text = "Send Code",
                        fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.bodyLarge
                    )
                }
            }

            Spacer(modifier = Modifier.height(40.dp))
        }

        // Country Selection Dialog
        if (showCountryPicker) {
            AlertDialog(
                onDismissRequest = { showCountryPicker = false },
                title = {
                    Text(
                        text = "Select Country",
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Black,
                        color = CoffeeInk
                    )
                },
                text = {
                    LazyColumn(
                        modifier = Modifier
                            .fillMaxWidth()
                            .heightIn(max = 300.dp)
                    ) {
                        items(CountryList) { country ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable {
                                        selectedCountry = country
                                        onPhoneChanged(country.dialCode + localNumber)
                                        showCountryPicker = false
                                    }
                                    .padding(vertical = 12.dp, horizontal = 8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = country.flag,
                                    fontSize = 22.sp,
                                    modifier = Modifier.padding(end = 12.dp)
                                )
                                Text(
                                    text = country.name,
                                    modifier = Modifier.weight(1f),
                                    style = MaterialTheme.typography.bodyLarge,
                                    color = CoffeeInk,
                                    fontWeight = FontWeight.Medium
                                )
                                Text(
                                    text = country.dialCode,
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = CoffeeMuted,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }
                },
                confirmButton = {},
                dismissButton = {
                    TextButton(onClick = { showCountryPicker = false }) {
                        Text("Cancel", color = CoffeeMuted, fontWeight = FontWeight.Bold)
                    }
                },
                containerColor = CoffeeSurface,
                shape = RoundedCornerShape(24.dp)
            )
        }
    }
}

// MARK: - OTP Verification View
@Composable
private fun OtpVerificationView(
    uiState: AuthUiState,
    onCodeChanged: (String) -> Unit,
    onVerifyOtp: () -> Unit,
    onResendCode: (Activity) -> Unit,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    val activity = context.findActivity()

    val focusRequester = remember { FocusRequester() }
    var isTextFieldFocused by remember { mutableStateOf(false) }

    val isCodeComplete = uiState.otpCode.length == 6

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = 24.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.Start
        ) {
            // Back button
            Box(
                modifier = Modifier
                    .padding(top = 24.dp, bottom = 24.dp)
                    .size(48.dp)
                    .shadow(
                        elevation = 8.dp,
                        shape = CircleShape,
                        ambientColor = Color.Black.copy(alpha = 0.04f),
                        spotColor = Color.Black.copy(alpha = 0.04f)
                    )
                    .clip(CircleShape)
                    .background(CoffeeSurface)
                    .border(1.dp, CoffeeBorder, CircleShape)
                    .clickable(onClick = onBack),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.AutoMirrored.Rounded.ArrowBack,
                    contentDescription = "Back",
                    tint = CoffeeInk,
                    modifier = Modifier.size(20.dp)
                )
            }

            Text(
                text = "Verify it's you",
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Black,
                color = CoffeeInk,
                modifier = Modifier.padding(bottom = 12.dp)
            )

            Text(
                text = "Enter the 6-digit code sent to ${uiState.phoneNumber}",
                style = MaterialTheme.typography.bodyLarge,
                color = CoffeeMuted,
                lineHeight = 22.sp,
                modifier = Modifier.padding(bottom = 44.dp)
            )

            // Digit entry fields
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 24.dp)
            ) {
                // Invisible overlay TextField to handle keyboard input
                BasicTextField(
                    value = uiState.otpCode,
                    onValueChange = { newValue ->
                        val digits = newValue.filter { it.isDigit() }
                        if (digits.length <= 6) {
                            onCodeChanged(digits)
                        }
                    },
                    keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                    modifier = Modifier
                        .size(1.dp)
                        .alpha(0.01f)
                        .focusRequester(focusRequester)
                        .onFocusChanged { isTextFieldFocused = it.isFocused }
                )

                // 6 Boxes visible to user
                Row(
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable { focusRequester.requestFocus() }
                ) {
                    for (i in 0 until 6) {
                        val char = if (i < uiState.otpCode.length) uiState.otpCode[i].toString() else ""
                        val isCurrent = i == uiState.otpCode.length
                        val isFilled = i < uiState.otpCode.length

                        Box(
                            modifier = Modifier
                                .weight(1f)
                                .height(62.dp)
                                .shadow(
                                    elevation = 8.dp,
                                    shape = RoundedCornerShape(16.dp),
                                    ambientColor = Color.Black.copy(alpha = 0.04f),
                                    spotColor = Color.Black.copy(alpha = 0.04f)
                                )
                                .clip(RoundedCornerShape(16.dp))
                                .background(CoffeeSurface)
                                .border(
                                    width = if (isCurrent && isTextFieldFocused) 2.dp else if (isFilled) 2.dp else 1.dp,
                                    color = if (isCurrent && isTextFieldFocused) CoffeePrimary else if (isFilled) CoffeePrimary else CoffeeBorder,
                                    shape = RoundedCornerShape(16.dp)
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = char,
                                style = MaterialTheme.typography.titleLarge.copy(fontSize = 22.sp),
                                color = CoffeeInk,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }

            // Resend Code pill
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 10.dp, horizontal = 36.dp),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .clip(CircleShape)
                        .background(CoffeeSurfaceSecondary)
                        .clickable(enabled = !uiState.isLoading && activity != null) {
                            if (activity != null) onResendCode(activity)
                        }
                        .padding(horizontal = 24.dp, vertical = 10.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = if (uiState.isLoading) "Sending..." else "Resend code",
                        style = MaterialTheme.typography.bodyMedium,
                        fontWeight = FontWeight.Bold,
                        color = CoffeePrimary
                    )
                }
            }

            // Error display
            uiState.errorMessage?.let { error ->
                Text(
                    text = error,
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeError,
                    modifier = Modifier.padding(top = 16.dp, start = 4.dp)
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // CTA Button
            Button(
                onClick = onVerifyOtp,
                enabled = isCodeComplete && !uiState.isLoading,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(64.dp)
                    .shadow(
                        elevation = if (isCodeComplete) 12.dp else 0.dp,
                        shape = RoundedCornerShape(16.dp),
                        ambientColor = CoffeePrimary.copy(alpha = 0.22f),
                        spotColor = CoffeePrimary.copy(alpha = 0.22f)
                    ),
                colors = ButtonDefaults.buttonColors(
                    containerColor = CoffeePrimary,
                    contentColor = Color.White,
                    disabledContainerColor = CoffeeMuted.copy(alpha = 0.24f),
                    disabledContentColor = CoffeeMuted
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                if (uiState.isLoading) {
                    CircularProgressIndicator(
                        color = Color.White,
                        modifier = Modifier.size(24.dp),
                        strokeWidth = 2.dp
                    )
                } else {
                    Text(
                        text = "Verify",
                        fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.bodyLarge
                    )
                }
            }

            Spacer(modifier = Modifier.height(40.dp))
        }

        // Request keyboard focus immediately on screen load
        LaunchedEffect(Unit) {
            focusRequester.requestFocus()
        }
    }
}

// MARK: - Context Helpers
private tailrec fun Context.findActivity(): Activity? =
    when (this) {
        is Activity -> this
        is ContextWrapper -> baseContext.findActivity()
        else -> null
    }
