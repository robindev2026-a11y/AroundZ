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
            .padding(horizontal = CoffeeSpacing.xl)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.Start
        ) {
            // Back button
            Box(
                modifier = Modifier
                    .padding(top = CoffeeSpacing.xl, bottom = CoffeeSpacing.xl)
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
                    modifier = Modifier.size(CoffeeSpacing.lg)
                )
            }

            Text(
                text = "What's your number?",
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Black,
                color = CoffeeInk,
                modifier = Modifier.padding(bottom = CoffeeSpacing.sm)
            )

            Text(
                text = "We'll send you a verification code to keep your account secure.",
                style = MaterialTheme.typography.bodyLarge,
                color = CoffeeMuted,
                lineHeight = 22.sp,
                modifier = Modifier.padding(bottom = CoffeeSpacing.xxl)
            )

            // Input fields
            Text(
                text = "PHONE NUMBER",
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.Black,
                color = CoffeeMuted,
                letterSpacing = 1.0.sp,
                modifier = Modifier.padding(bottom = CoffeeSpacing.xs, start = CoffeeSpacing.xxs)
            )

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm),
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Country Code Selector
                Box(
                    modifier = Modifier
                        .height(CoffeeSpacing.primaryButtonHeight)
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
                        .padding(horizontal = CoffeeSpacing.sm),
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
                            modifier = Modifier.size(CoffeeSpacing.lg)
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
                        .height(CoffeeSpacing.primaryButtonHeight)
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
                    modifier = Modifier.padding(top = CoffeeSpacing.sm, start = CoffeeSpacing.xxs)
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // CTA Button
            CoffeeButton(
                title = if (uiState.isLoading) "Sending..." else "Send Code",
                onClick = { activity?.let { onSendOtp(it) } },
                variant = CoffeeButtonVariant.Primary,
                enabled = isPhoneValid && !uiState.isLoading,
                height = CoffeeSpacing.primaryButtonHeight
            )

            Text(
                text = "Standard SMS rates may apply. You'll receive a 6-digit code to verify your phone.",
                style = MaterialTheme.typography.labelMedium,
                color = CoffeeMuted.copy(alpha = 0.8f),
                lineHeight = 16.sp,
                modifier = Modifier.padding(top = CoffeeSpacing.md, start = CoffeeSpacing.xxs)
            )
        }

        // Country code picker sheet
        if (showCountryPicker) {
            CountryCodePicker(
                selectedCountry = selectedCountry,
                onCountrySelected = { country ->
                    selectedCountry = country
                    showCountryPicker = false
                    onPhoneChanged(country.dialCode + localNumber)
                },
                onDismiss = { showCountryPicker = false }
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
    val codeLength = 6
    var localCode by remember { mutableStateOf("") }

    val isCodeComplete = localCode.length == codeLength

    LaunchedEffect(uiState.otpCode) {
        if (uiState.otpCode.isNotEmpty() && localCode.isEmpty()) {
            localCode = uiState.otpCode
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
            .statusBarsPadding()
            .navigationBarsPadding()
            .padding(horizontal = CoffeeSpacing.xl)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.Start
        ) {
            // Back button
            Box(
                modifier = Modifier
                    .padding(top = CoffeeSpacing.xl, bottom = CoffeeSpacing.xl)
                    .size(CoffeeSpacing.minTouchTarget)
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
                    modifier = Modifier.size(CoffeeSpacing.lg)
                )
            }

            Text(
                text = "Enter the code",
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Black,
                color = CoffeeInk,
                modifier = Modifier.padding(bottom = CoffeeSpacing.sm)
            )

            Text(
                text = "We sent a 6-digit code to ${uiState.phoneNumber}",
                style = MaterialTheme.typography.bodyLarge,
                color = CoffeeMuted,
                modifier = Modifier.padding(bottom = CoffeeSpacing.xxl)
            )

            // OTP Character boxes
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs)
            ) {
                for (i in 0 until codeLength) {
                    val char = localCode.getOrNull(i)?.toString() ?: ""
                    val isFocused = i == localCode.length

                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .height(CoffeeSpacing.minTouchTarget)
                            .shadow(
                                elevation = if (isFocused) 4.dp else 0.dp,
                                shape = RoundedCornerShape(CoffeeSpacing.sm)
                            )
                            .clip(RoundedCornerShape(CoffeeSpacing.sm))
                            .background(if (char.isNotEmpty()) CoffeePrimary.copy(alpha = 0.1f) else CoffeeSurface)
                            .border(
                                1.dp,
                                if (isFocused) CoffeePrimary else CoffeeBorder,
                                RoundedCornerShape(CoffeeSpacing.sm)
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = char,
                            style = MaterialTheme.typography.headlineMedium,
                            fontWeight = FontWeight.Bold,
                            color = CoffeeInk
                        )
                    }
                }
            }

            // Hidden text field for keyboard input
            BasicTextField(
                value = localCode,
                onValueChange = { newValue ->
                    val filtered = newValue.filter { it.isDigit() }.take(codeLength)
                    localCode = filtered
                    onCodeChanged(filtered)
                },
                modifier = Modifier
                    .focusRequester(focusRequester)
                    .alpha(0f)
                    .size(0.dp),
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number)
            )

            // Error message
            uiState.errorMessage?.let { error ->
                Text(
                    text = error,
                    style = MaterialTheme.typography.bodyMedium,
                    color = CoffeeError,
                    modifier = Modifier.padding(top = CoffeeSpacing.sm)
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // CTA Button
            CoffeeButton(
                title = if (uiState.isLoading) "Verifying..." else "Verify",
                onClick = onVerifyOtp,
                variant = CoffeeButtonVariant.Primary,
                enabled = isCodeComplete && !uiState.isLoading,
                height = CoffeeSpacing.primaryButtonHeight
            )

            Spacer(modifier = Modifier.height(CoffeeSpacing.xl))
        }

        // Request keyboard focus immediately on screen load
        LaunchedEffect(Unit) {
            focusRequester.requestFocus()
        }
    }
}

// MARK: - Country Code Picker
@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun CountryCodePicker(
    selectedCountry: CountryCode,
    onCountrySelected: (CountryCode) -> Unit,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = CoffeeSurface,
        shape = CoffeeShapes.xlarge
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = CoffeeSpacing.xl)
                .padding(bottom = CoffeeSpacing.xxl)
        ) {
            Text(
                text = "Select Country",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold,
                color = CoffeeInk,
                modifier = Modifier.padding(bottom = CoffeeSpacing.md)
            )

            LazyColumn(
                modifier = Modifier.fillMaxWidth()
            ) {
                items(CountryList) { country ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { onCountrySelected(country) }
                            .padding(vertical = CoffeeSpacing.sm)
                            .then(
                                if (country.id == selectedCountry.id) Modifier.background(CoffeePrimary.copy(alpha = 0.1f), CoffeeShapes.small)
                                else Modifier
                            ),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Text(text = country.flag, fontSize = 24.sp, modifier = Modifier.padding(end = CoffeeSpacing.sm))
                        Column(modifier = Modifier.weight(1f)) {
                            Text(text = country.name, style = MaterialTheme.typography.bodyLarge, color = CoffeeInk)
                            Text(text = country.dialCode, style = MaterialTheme.typography.bodyMedium, color = CoffeeMuted)
                        }
                        if (country.id == selectedCountry.id) {
                            Icon(
                                imageVector = Icons.Rounded.ChevronRight,
                                contentDescription = null,
                                tint = CoffeePrimary,
                                modifier = Modifier.size(CoffeeSpacing.lg)
                            )
                        }
                    }
                }
            }
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
