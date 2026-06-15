package com.coffeecall.app.feature.auth

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.coffeecall.app.core.design.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileSetupScreen(
    uiState: AuthUiState,
    onNameChanged: (String) -> Unit,
    onSaveProfile: (ByteArray?) -> Unit
) {
    val context = LocalContext.current
    val scope = rememberCoroutineScope()
    var pickedImageUri by remember { mutableStateOf<Uri?>(null) }
    var photoBytes by remember { mutableStateOf<ByteArray?>(null) }

    val photoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri ->
        if (uri != null) {
            pickedImageUri = uri
            scope.launch {
                runCatching {
                    val inputStream = context.contentResolver.openInputStream(uri)
                    val bitmap = android.graphics.BitmapFactory.decodeStream(inputStream)
                    val outputStream = java.io.ByteArrayOutputStream()
                    bitmap.compress(android.graphics.Bitmap.CompressFormat.JPEG, 80, outputStream)
                    photoBytes = outputStream.toByteArray()
                }
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
            .padding(horizontal = CoffeeSpacing.screen)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.Center,
            horizontalAlignment = Alignment.Start
        ) {
            Text(
                text = "Set up your profile",
                style = MaterialTheme.typography.displaySmall,
                fontWeight = FontWeight.Black,
                color = CoffeeInk,
                modifier = Modifier.padding(bottom = CoffeeSpacing.xs)
            )

            Text(
                text = "Add your name and photo so hosts and participants know who joined.",
                style = MaterialTheme.typography.bodyMedium,
                color = CoffeeMuted,
                modifier = Modifier.padding(bottom = CoffeeSpacing.xxl)
            )

            // Avatar Upload section
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = CoffeeSpacing.xxl),
                contentAlignment = Alignment.Center
            ) {
                Box(
                    modifier = Modifier
                        .size(140.dp)
                        .clip(RoundedCornerShape(48.dp))
                        .background(CoffeeSurfaceSecondary)
                        .border(
                            width = 2.dp,
                            color = if (pickedImageUri != null) CoffeePrimary.copy(alpha = 0.4f) else CoffeeBorder,
                            shape = RoundedCornerShape(48.dp)
                        )
                        .clickable {
                            photoPickerLauncher.launch(
                                PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                            )
                        },
                    contentAlignment = Alignment.Center
                ) {
                    if (pickedImageUri != null) {
                        AsyncImage(
                            model = pickedImageUri,
                            contentDescription = "Profile photo preview",
                            modifier = Modifier.fillMaxSize(),
                            contentScale = ContentScale.Crop
                        )
                    } else {
                        Column(
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Text(
                                text = "📷",
                                fontSize = 38.sp
                            )
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(
                                text = "Add Photo",
                                style = MaterialTheme.typography.labelSmall,
                                color = CoffeeMuted
                            )
                        }
                    }
                }
            }

            // Name input label
            Text(
                text = "DISPLAY NAME",
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.Black,
                color = CoffeeMuted,
                modifier = Modifier.padding(bottom = 6.dp)
            )

            OutlinedTextField(
                value = uiState.profileName,
                onValueChange = onNameChanged,
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(elevation = 6.dp, shape = CoffeeShapes.small)
                    .background(CoffeeSurface, CoffeeShapes.small),
                placeholder = { Text("e.g. Siddharth", color = CoffeeMuted) },
                singleLine = true,
                enabled = !uiState.isLoading,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = CoffeeInk,
                    unfocusedTextColor = CoffeeInk,
                    focusedBorderColor = CoffeePrimary,
                    unfocusedBorderColor = Color.Transparent
                ),
                shape = CoffeeShapes.small
            )

            Text(
                text = "This is what other people will see.",
                style = MaterialTheme.typography.labelSmall,
                color = CoffeeMuted,
                modifier = Modifier.padding(top = 6.dp)
            )

            uiState.errorMessage?.let { message ->
                Text(
                    text = message,
                    style = MaterialTheme.typography.bodySmall,
                    color = CoffeeError,
                    modifier = Modifier.padding(top = CoffeeSpacing.md)
                )
            }

            Spacer(modifier = Modifier.height(CoffeeSpacing.xxl))

            // CTA Button
            val isReady = uiState.profileName.isNotBlank()
            Button(
                onClick = { onSaveProfile(photoBytes) },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(56.dp)
                    .shadow(
                        elevation = if (isReady) 12.dp else 0.dp,
                        shape = CoffeeShapes.small,
                        ambientColor = CoffeePrimary.copy(alpha = 0.22f),
                        spotColor = CoffeePrimary.copy(alpha = 0.22f)
                    ),
                enabled = isReady && !uiState.isLoading,
                colors = ButtonDefaults.buttonColors(
                    containerColor = CoffeePrimary,
                    contentColor = CoffeeTextOnBrand,
                    disabledContainerColor = CoffeeMuted.copy(alpha = 0.24f),
                    disabledContentColor = CoffeeMuted
                ),
                shape = CoffeeShapes.small
            ) {
                if (uiState.isLoading) {
                    CircularProgressIndicator(color = CoffeeTextOnBrand, modifier = Modifier.size(24.dp))
                } else {
                    Text(
                        text = "Continue",
                        fontWeight = FontWeight.Black,
                        style = MaterialTheme.typography.titleMedium
                    )
                }
            }
        }
    }
}
