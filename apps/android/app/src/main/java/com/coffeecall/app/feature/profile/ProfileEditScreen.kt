package com.coffeecall.app.feature.profile

import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import com.coffeecall.app.core.design.*
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class, ExperimentalLayoutApi::class)
@Composable
fun ProfileEditScreen(
    viewModel: ProfileViewModel,
    onBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()


    var nameText by remember { mutableStateOf("") }
    var bioText by remember { mutableStateOf("") }
    var locationText by remember { mutableStateOf("") }

    var eveningsSelected by remember { mutableStateOf(true) }
    var weekendsSelected by remember { mutableStateOf(true) }
    var daytimeSelected by remember { mutableStateOf(false) }

    var selectedInterests by remember { mutableStateOf<List<String>>(emptyList()) }
    var pickedImageUri by remember { mutableStateOf<Uri?>(null) }
    var removePhotoFlag by remember { mutableStateOf(false) }

    val photoPickerLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.PickVisualMedia()
    ) { uri ->
        if (uri != null) {
            pickedImageUri = uri
            removePhotoFlag = false
        }
    }

    // Initialize values when user data becomes available
    LaunchedEffect(uiState.user) {
        uiState.user?.let { user ->
            nameText = user.name
            bioText = user.bio
            locationText = user.location
            eveningsSelected = user.availabilityWeekdayEvenings
            weekendsSelected = user.availabilityWeekends
            daytimeSelected = user.availabilityDaytime
            selectedInterests = user.interests
        }
    }

    // Back on success
    LaunchedEffect(uiState.success) {
        if (uiState.success) {
            viewModel.clearSuccess()
            onBack()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = CoffeeSpacing.screen)
        ) {
            Spacer(modifier = Modifier.height(72.dp)) // Header spacing

            // Profile Photo section
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = CoffeeSpacing.md),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Box(
                        modifier = Modifier
                            .size(120.dp)
                            .clip(RoundedCornerShape(40.dp))
                            .background(CoffeeSurfaceSecondary)
                            .border(1.dp, CoffeeBorder, RoundedCornerShape(40.dp))
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
                                contentDescription = "New Profile photo",
                                modifier = Modifier.fillMaxSize(),
                                contentScale = ContentScale.Crop
                            )
                        } else if (!removePhotoFlag && uiState.user?.profilePhotoUrl.orEmpty().isNotBlank()) {
                            AsyncImage(
                                model = uiState.user?.profilePhotoUrl,
                                contentDescription = "Profile photo",
                                modifier = Modifier.fillMaxSize(),
                                contentScale = ContentScale.Crop
                            )
                        } else {
                            val initials = uiState.user?.initials.orEmpty().ifBlank { "U" }
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(CoffeePurple.copy(alpha = 0.16f)),
                                contentAlignment = Alignment.Center
                            ) {
                                Text(
                                    text = initials,
                                    fontSize = 32.sp,
                                    color = CoffeePurple,
                                    fontWeight = FontWeight.Black
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(CoffeeSpacing.sm))

                    Row(horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.sm)) {
                        Text(
                            text = "Choose Photo",
                            color = CoffeePrimary,
                            style = MaterialTheme.typography.labelMedium,
                            fontWeight = FontWeight.Bold,
                            modifier = Modifier
                                .clickable {
                                    photoPickerLauncher.launch(
                                        PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly)
                                    )
                                }
                                .padding(horizontal = 8.dp, vertical = 4.dp)
                        )

                        val hasPhoto = pickedImageUri != null || (uiState.user?.profilePhotoUrl.orEmpty().isNotBlank() && !removePhotoFlag)
                        if (hasPhoto) {
                            Text(
                                text = "Remove",
                                color = CoffeeError,
                                style = MaterialTheme.typography.labelMedium,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier
                                    .clickable {
                                        pickedImageUri = null
                                        removePhotoFlag = true
                                    }
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            )
                        }
                    }
                }
            }

            // Input Fields
            Text(
                text = "DISPLAY NAME",
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.Black,
                color = CoffeeMuted,
                modifier = Modifier.padding(bottom = 6.dp)
            )
            OutlinedTextField(
                value = nameText,
                onValueChange = { nameText = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .shadow(4.dp, CoffeeShapes.small)
                    .background(CoffeeSurface, CoffeeShapes.small),
                singleLine = true,
                shape = CoffeeShapes.small,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = CoffeeInk,
                    unfocusedTextColor = CoffeeInk,
                    focusedBorderColor = CoffeePrimary,
                    unfocusedBorderColor = Color.Transparent
                )
            )

            Spacer(modifier = Modifier.height(CoffeeSpacing.md))

            Text(
                text = "ABOUT YOU",
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.Black,
                color = CoffeeMuted,
                modifier = Modifier.padding(bottom = 6.dp)
            )
            OutlinedTextField(
                value = bioText,
                onValueChange = { bioText = it },
                modifier = Modifier
                    .fillMaxWidth()
                    .height(96.dp)
                    .shadow(4.dp, CoffeeShapes.small)
                    .background(CoffeeSurface, CoffeeShapes.small),
                shape = CoffeeShapes.small,
                colors = OutlinedTextFieldDefaults.colors(
                    focusedTextColor = CoffeeInk,
                    unfocusedTextColor = CoffeeInk,
                    focusedBorderColor = CoffeePrimary,
                    unfocusedBorderColor = Color.Transparent
                )
            )

            Spacer(modifier = Modifier.height(CoffeeSpacing.md))

            Text(
                text = "LOCATION",
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.Black,
                color = CoffeeMuted,
                modifier = Modifier.padding(bottom = 6.dp)
            )
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                modifier = Modifier.fillMaxWidth()
            ) {
                OutlinedTextField(
                    value = locationText,
                    onValueChange = { locationText = it },
                    modifier = Modifier
                        .weight(1f)
                        .shadow(4.dp, CoffeeShapes.small)
                        .background(CoffeeSurface, CoffeeShapes.small),
                    singleLine = true,
                    shape = CoffeeShapes.small,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedTextColor = CoffeeInk,
                        unfocusedTextColor = CoffeeInk,
                        focusedBorderColor = CoffeePrimary,
                        unfocusedBorderColor = Color.Transparent
                    )
                )

                // GPS button
                Button(
                    onClick = {
                        viewModel.fetchLocationAndAddress { resolved ->
                            locationText = resolved
                        }
                    },
                    modifier = Modifier.size(56.dp),
                    shape = CoffeeShapes.small,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = CoffeeSurface,
                        contentColor = CoffeePrimary
                    ),
                    contentPadding = PaddingValues(0.dp),
                    border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder)
                ) {
                    Text("📍", fontSize = 18.sp)
                }
            }

            Spacer(modifier = Modifier.height(CoffeeSpacing.lg))

            // Availability Checklist
            Text(
                text = "WEEKLY AVAILABILITY",
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.Black,
                color = CoffeeMuted,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            Surface(
                modifier = Modifier.fillMaxWidth(),
                shape = CoffeeShapes.medium,
                color = CoffeeSurface,
                border = androidx.compose.foundation.BorderStroke(1.dp, CoffeeBorder)
            ) {
                Column(modifier = Modifier.padding(CoffeeSpacing.md)) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { eveningsSelected = !eveningsSelected }
                            .padding(vertical = CoffeeSpacing.xs),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Checkbox(
                            checked = eveningsSelected,
                            onCheckedChange = { eveningsSelected = it },
                            colors = CheckboxDefaults.colors(checkedColor = CoffeePrimary)
                        )
                        Spacer(modifier = Modifier.width(CoffeeSpacing.xs))
                        Text("Weekday Evenings", color = CoffeeInk, style = MaterialTheme.typography.bodyMedium)
                    }
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { weekendsSelected = !weekendsSelected }
                            .padding(vertical = CoffeeSpacing.xs),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Checkbox(
                            checked = weekendsSelected,
                            onCheckedChange = { weekendsSelected = it },
                            colors = CheckboxDefaults.colors(checkedColor = CoffeePrimary)
                        )
                        Spacer(modifier = Modifier.width(CoffeeSpacing.xs))
                        Text("Weekends", color = CoffeeInk, style = MaterialTheme.typography.bodyMedium)
                    }
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { daytimeSelected = !daytimeSelected }
                            .padding(vertical = CoffeeSpacing.xs),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Checkbox(
                            checked = daytimeSelected,
                            onCheckedChange = { daytimeSelected = it },
                            colors = CheckboxDefaults.colors(checkedColor = CoffeePrimary)
                        )
                        Spacer(modifier = Modifier.width(CoffeeSpacing.xs))
                        Text("Daytime", color = CoffeeInk, style = MaterialTheme.typography.bodyMedium)
                    }
                }
            }

            Spacer(modifier = Modifier.height(CoffeeSpacing.lg))

            // Interests Tag Selection
            Text(
                text = "YOUR INTERESTS",
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.Black,
                color = CoffeeMuted,
                modifier = Modifier.padding(bottom = 8.dp)
            )
            val availableInterests = listOf("coffee", "walk", "food", "movie", "study")
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                verticalArrangement = Arrangement.spacedBy(CoffeeSpacing.xs),
                modifier = Modifier.fillMaxWidth()
            ) {
                availableInterests.forEach { interest ->
                    val isSelected = selectedInterests.contains(interest)
                    val chipColor = if (isSelected) CoffeePrimary else CoffeeSurface
                    val textColor = if (isSelected) CoffeeTextOnBrand else CoffeeInk
                    val borderColor = if (isSelected) Color.Transparent else CoffeeBorder

                    Surface(
                        onClick = {
                            selectedInterests = if (isSelected) {
                                selectedInterests.filter { it != interest }
                            } else {
                                selectedInterests + interest
                            }
                        },
                        shape = CircleShape,
                        color = chipColor,
                        border = androidx.compose.foundation.BorderStroke(1.dp, borderColor),
                        modifier = Modifier.height(36.dp)
                    ) {
                        Box(
                            modifier = Modifier.padding(horizontal = CoffeeSpacing.md),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = interest.replaceFirstChar { it.uppercase() },
                                color = textColor,
                                style = MaterialTheme.typography.labelMedium,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }
            }

            Spacer(modifier = Modifier.height(120.dp)) // Spacer for bottom
        }

        // Top Header bar
        Surface(
            modifier = Modifier
                .align(Alignment.TopCenter)
                .fillMaxWidth(),
            color = CoffeeBackground.copy(alpha = 0.94f),
            shadowElevation = 0.dp
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = CoffeeSpacing.xs)
                    .padding(horizontal = CoffeeSpacing.screen)
                    .height(56.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "← Cancel",
                    color = CoffeeInk,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    modifier = Modifier.clickable(onClick = onBack)
                )

                Spacer(modifier = Modifier.weight(1f))

                if (uiState.isSaving) {
                    CircularProgressIndicator(color = CoffeePrimary, modifier = Modifier.size(24.dp))
                } else {
                    Text(
                        text = "Save",
                        color = CoffeePrimary,
                        style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.Black,
                        modifier = Modifier.clickable {
                            viewModel.updateProfile(
                                name = nameText,
                                bio = bioText,
                                location = locationText,
                                availabilityWeekdayEvenings = eveningsSelected,
                                availabilityWeekends = weekendsSelected,
                                availabilityDaytime = daytimeSelected,
                                interests = selectedInterests,
                                photoUri = pickedImageUri,
                                removePhoto = removePhotoFlag
                            )
                        }
                    )
                }
            }
        }

        // Error message popup
        uiState.error?.let { err ->
            Snackbar(
                action = {
                    TextButton(onClick = viewModel::clearError) {
                        Text("OK", color = CoffeeTextOnBrand)
                    }
                },
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .padding(CoffeeSpacing.md)
            ) {
                Text(err)
            }
        }
    }
}
