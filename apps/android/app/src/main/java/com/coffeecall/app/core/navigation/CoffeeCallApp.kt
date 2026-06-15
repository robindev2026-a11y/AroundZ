package com.coffeecall.app.core.navigation

import android.app.Application
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import android.os.Build
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.Column
import androidx.compose.runtime.remember
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.TextButton
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.runtime.LaunchedEffect
import com.coffeecall.app.core.design.CoffeePeach
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.coffeecall.app.core.design.CoffeeBackground
import com.coffeecall.app.core.design.CoffeeBorder
import com.coffeecall.app.core.design.CoffeeCallTheme
import com.coffeecall.app.core.design.CoffeeDarkOverlay
import com.coffeecall.app.core.design.CoffeeInk
import com.coffeecall.app.core.design.CoffeeMuted
import com.coffeecall.app.core.design.CoffeePrimary
import com.coffeecall.app.core.design.CoffeePrimaryDark
import com.coffeecall.app.core.design.CoffeeShapes
import com.coffeecall.app.core.design.CoffeeSpacing
import com.coffeecall.app.core.design.CoffeeSurface
import com.coffeecall.app.core.design.CoffeeTextOnBrand
import com.coffeecall.app.core.design.CoffeeTopAppBar
import com.coffeecall.app.feature.auth.AuthRoute
import com.coffeecall.app.feature.auth.AuthScreen
import com.coffeecall.app.feature.auth.AuthViewModel
import com.coffeecall.app.feature.auth.ProfileSetupScreen
import com.coffeecall.app.feature.chat.ChatScreen
import com.coffeecall.app.feature.chat.ChatThreadScreen
import com.coffeecall.app.feature.create.CreateScreen
import com.coffeecall.app.feature.discovery.DiscoveryScreen
import com.coffeecall.app.feature.drifts.DriftsScreen
import com.coffeecall.app.feature.onboarding.OnboardingScreen
import com.coffeecall.app.feature.profile.ProfileScreen
import com.coffeecall.app.feature.profile.ProfileEditScreen
import com.coffeecall.app.feature.profile.ProfileViewModel
import com.coffeecall.app.feature.driftDetail.DriftDetailScreen

@Composable
fun CoffeeCallApp() {
    val application = LocalContext.current.applicationContext as Application
    val authViewModel: AuthViewModel = viewModel(
        factory = AuthViewModel.factory(application)
    )
    val uiState by authViewModel.uiState.collectAsState()

    when (uiState.route) {
        AuthRoute.Loading -> LoadingScreen()
        AuthRoute.Onboarding -> OnboardingScreen(
            onContinue = authViewModel::continueFromOnboarding
        )
        AuthRoute.Auth -> AuthScreen(
            uiState = uiState,
            onPhoneChanged = authViewModel::updatePhoneNumber,
            onCodeChanged = authViewModel::updateOtpCode,
            onSendOtp = authViewModel::sendOtp,
            onVerifyOtp = authViewModel::verifyOtp,
            onBackFromOtp = authViewModel::resetVerificationState,
            onBackToOnboarding = authViewModel::backToOnboarding
        )
        AuthRoute.ProfileSetup -> ProfileSetupScreen(
            uiState = uiState,
            onNameChanged = authViewModel::updateProfileName,
            onSaveProfile = authViewModel::saveProfile
        )
        AuthRoute.App -> CoffeeCallAppShell(
            onSignOut = authViewModel::signOut
        )
    }
}

@Composable
private fun LoadingScreen() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground),
        contentAlignment = Alignment.Center
    ) {
        CircularProgressIndicator(color = CoffeePrimary)
    }
}

@Composable
private fun CoffeeCallAppShell(
    onSignOut: () -> Unit
) {
    val navController = rememberNavController()
    val backStackEntry by navController.currentBackStackEntryAsState()
    val currentDestination = backStackEntry?.destination
    val selectedDestination = CoffeeCallDestinations.firstOrNull { destination ->
        currentDestination?.hierarchy?.any { it.route == destination.route } == true
    } ?: CoffeeCallDestinations.first()

    val context = LocalContext.current
    val networkMonitor = remember { com.coffeecall.app.core.common.NetworkMonitor(context) }
    val isOnline by networkMonitor.isOnline.collectAsState(initial = true)

    var showNotificationDialog by remember { mutableStateOf(false) }
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { }

    LaunchedEffect(Unit) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            val hasPermission = ContextCompat.checkSelfPermission(
                context,
                android.Manifest.permission.POST_NOTIFICATIONS
            ) == PackageManager.PERMISSION_GRANTED
            if (!hasPermission) {
                showNotificationDialog = true
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(CoffeeBackground)
    ) {
        NavHost(
            navController = navController,
            startDestination = CoffeeCallRoutes.DISCOVERY,
            modifier = Modifier.fillMaxSize()
        ) {
            composable(CoffeeCallRoutes.DISCOVERY) {
                DiscoveryScreen(
                    onDriftClick = { id ->
                        navController.navigate("drift_detail/$id")
                    },
                    onNavigateToCreate = {
                        navController.navigate(CoffeeCallRoutes.CREATE) {
                            popUpTo(navController.graph.startDestinationId) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }
            composable(CoffeeCallRoutes.DRIFTS) {
                DriftsScreen(
                    onDriftClick = { id ->
                        navController.navigate("drift_detail/$id")
                    }
                )
            }
            composable(CoffeeCallRoutes.CREATE) {
                CreateScreen(
                    onCreated = {
                        navController.navigate(CoffeeCallRoutes.DRIFTS) {
                            popUpTo(navController.graph.startDestinationId) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    }
                )
            }
            composable(CoffeeCallRoutes.CHAT) {
                ChatScreen(
                    onThreadClick = { threadId ->
                        navController.navigate("chat_thread/$threadId")
                    }
                )
            }
            composable(
                route = CoffeeCallRoutes.CHAT_THREAD,
                arguments = listOf(
                    androidx.navigation.navArgument("threadId") {
                        type = androidx.navigation.NavType.StringType
                    }
                ),
                deepLinks = listOf(
                    androidx.navigation.navDeepLink {
                        uriPattern = "coffeecall://chat_thread/{threadId}"
                    },
                    androidx.navigation.navDeepLink {
                        uriPattern = "https://coffeecall.app/chat_thread/{threadId}"
                    }
                )
            ) { backStackEntry ->
                val threadId = backStackEntry.arguments?.getString("threadId").orEmpty()
                ChatThreadScreen(
                    threadId = threadId,
                    onBack = { navController.popBackStack() },
                    onNavigateToDrift = { id ->
                        navController.navigate("drift_detail/$id")
                    }
                )
            }
            composable(CoffeeCallRoutes.PROFILE) {
                ProfileScreen(
                    onEditClick = {
                        navController.navigate(CoffeeCallRoutes.PROFILE_EDIT)
                    }
                )
            }
            composable(CoffeeCallRoutes.PROFILE_EDIT) {
                val app = LocalContext.current.applicationContext as Application
                val profileViewModel: ProfileViewModel = viewModel(
                    factory = ProfileViewModel.factory(app)
                )
                ProfileEditScreen(
                    viewModel = profileViewModel,
                    onBack = { navController.popBackStack() }
                )
            }
            composable(
                route = CoffeeCallRoutes.DRIFT_DETAIL,
                arguments = listOf(
                    androidx.navigation.navArgument("postId") {
                        type = androidx.navigation.NavType.StringType
                    }
                ),
                deepLinks = listOf(
                    androidx.navigation.navDeepLink {
                        uriPattern = "coffeecall://drift/{postId}"
                    },
                    androidx.navigation.navDeepLink {
                        uriPattern = "https://coffeecall.app/drift/{postId}"
                    }
                )
            ) { backStackEntry ->
                val postId = backStackEntry.arguments?.getString("postId").orEmpty()
                DriftDetailScreen(
                    postId = postId,
                    onBack = { navController.popBackStack() },
                    onNavigateToDrift = { id ->
                        navController.navigate("drift_detail/$id")
                    }
                )
            }
        }

        if (selectedDestination.route != CoffeeCallRoutes.DISCOVERY) {
            Column(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .fillMaxWidth()
            ) {
                Surface(
                    modifier = Modifier.fillMaxWidth(),
                    color = CoffeeBackground.copy(alpha = 0.96f),
                    shadowElevation = 0.dp
                ) {
                    CoffeeTopAppBar(
                        title = selectedDestination.label,
                        subtitle = selectedDestination.subtitle,
                        actionLabel = "Sign out",
                        onAction = onSignOut,
                        modifier = Modifier
                            .padding(top = CoffeeSpacing.xs)
                    )
                }

                if (!isOnline) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .background(CoffeePeach)
                            .padding(vertical = 4.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Text(
                            text = "⚠️ Device is offline. Using local caches.",
                            color = Color.White,
                            style = MaterialTheme.typography.labelMedium,
                            fontWeight = FontWeight.Bold
                        )
                    }
                }
            }
        } else {
            if (!isOnline) {
                Box(
                    modifier = Modifier
                        .align(Alignment.TopCenter)
                        .fillMaxWidth()
                        .background(CoffeePeach)
                        .padding(vertical = 4.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "⚠️ Device is offline. Using local caches.",
                        color = Color.White,
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        }

        if (showNotificationDialog) {
            AlertDialog(
                onDismissRequest = { showNotificationDialog = false },
                title = { Text("Enable Notifications", color = CoffeeInk, fontWeight = FontWeight.Bold) },
                text = { Text("CoffeeCall needs notification access to alert you about meetup updates, host approvals, and new chat messages.", color = CoffeeMuted) },
                confirmButton = {
                    TextButton(onClick = {
                        showNotificationDialog = false
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            permissionLauncher.launch(android.Manifest.permission.POST_NOTIFICATIONS)
                        }
                    }) {
                        Text("Enable", color = CoffeePrimary, fontWeight = FontWeight.Bold)
                    }
                },
                dismissButton = {
                    TextButton(onClick = { showNotificationDialog = false }) {
                        Text("Not Now", color = CoffeeMuted)
                    }
                },
                containerColor = CoffeeSurface,
                shape = CoffeeShapes.medium
            )
        }

        BottomFade()
        CoffeeBottomNavigation(
            destinations = CoffeeCallDestinations,
            selectedRoute = selectedDestination.route,
            onDestinationClick = { destination ->
                navController.navigate(destination.route) {
                    popUpTo(navController.graph.startDestinationId) {
                        saveState = true
                    }
                    launchSingleTop = true
                    restoreState = true
                }
            },
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }
}

@Composable
private fun BoxScope.BottomFade() {
    Box(
        modifier = Modifier
            .align(Alignment.BottomCenter)
            .fillMaxWidth()
            .height(132.dp)
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color.Transparent,
                        CoffeeBackground.copy(alpha = 0.86f),
                        CoffeeBackground
                    )
                )
            )
    )
}

@Composable
private fun CoffeeBottomNavigation(
    destinations: List<CoffeeCallDestination>,
    selectedRoute: String,
    onDestinationClick: (CoffeeCallDestination) -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .navigationBarsPadding()
            .padding(horizontal = CoffeeSpacing.screen, vertical = CoffeeSpacing.bottomNavBottomPadding)
            .fillMaxWidth()
            .height(CoffeeSpacing.bottomNavHeight)
            .shadow(
                elevation = 18.dp,
                shape = CoffeeShapes.xlarge,
                ambientColor = CoffeeDarkOverlay.copy(alpha = 0.12f),
                spotColor = CoffeeDarkOverlay.copy(alpha = 0.12f)
            )
            .clip(CoffeeShapes.xlarge)
            .background(CoffeeSurface.copy(alpha = 0.94f))
            .border(1.dp, CoffeeBorder.copy(alpha = 0.72f), CoffeeShapes.xlarge)
            .padding(horizontal = CoffeeSpacing.xs, vertical = CoffeeSpacing.xs),
        verticalAlignment = Alignment.CenterVertically
    ) {
        destinations.forEach { destination ->
            val selected = destination.route == selectedRoute
            CoffeeBottomNavigationItem(
                destination = destination,
                selected = selected,
                onClick = { onDestinationClick(destination) },
                modifier = Modifier.weight(1f)
            )
        }
    }
}

@Composable
private fun CoffeeBottomNavigationItem(
    destination: CoffeeCallDestination,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    val background = if (selected) CoffeePrimary else Color.Transparent
    val content = if (selected) CoffeeTextOnBrand else CoffeeMuted

    Surface(
        onClick = onClick,
        modifier = modifier
            .height(56.dp)
            .padding(horizontal = 2.dp),
        shape = CoffeeShapes.large,
        color = background
    ) {
        Row(
            modifier = Modifier
                .padding(horizontal = 6.dp)
                .widthIn(min = 44.dp),
            horizontalArrangement = androidx.compose.foundation.layout.Arrangement.Center,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(if (selected) 32.dp else 28.dp)
                    .clip(CircleShape)
                    .background(if (selected) CoffeeTextOnBrand.copy(alpha = 0.18f) else Color.Transparent),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = destination.icon,
                    contentDescription = destination.label,
                    tint = if (selected) CoffeeTextOnBrand else CoffeeMuted,
                    modifier = Modifier.size(if (selected) 20.dp else 22.dp)
                )
            }
            if (selected) {
                Spacer(modifier = Modifier.padding(horizontal = 3.dp))
                Text(
                    text = destination.label,
                    style = MaterialTheme.typography.labelMedium,
                    color = content,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

@Preview(showBackground = true, widthDp = 320)
@Composable
private fun CoffeeBottomNavigationPreview() {
    CoffeeCallTheme {
        Box(
            modifier = Modifier
                .background(CoffeeBackground)
                .padding(top = 24.dp)
        ) {
            CoffeeBottomNavigation(
                destinations = CoffeeCallDestinations,
                selectedRoute = CoffeeCallRoutes.DISCOVERY,
                onDestinationClick = {}
            )
        }
    }
}
