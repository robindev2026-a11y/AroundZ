package com.coffeecall.app.core.navigation

import android.app.Application
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.statusBarsPadding
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
import com.coffeecall.app.core.design.CoffeeIcons
import com.coffeecall.app.core.design.CoffeeDarkOverlay
import com.coffeecall.app.core.design.CoffeeInk
import com.coffeecall.app.core.design.CoffeeMuted
import com.coffeecall.app.core.design.CoffeePrimary
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

    val navManager = remember { NavigationManager.getInstance() }
    val isTabBarHidden by navManager.isTabBarHidden.collectAsState()

    var showNotificationDialog by remember { mutableStateOf(false) }
    var showCreateSheet by remember { mutableStateOf(false) }
    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestPermission()
    ) { }

    val currentRoute = currentDestination?.route
    val isDetailOrChat = currentRoute != null && (
        currentRoute.startsWith("drift_detail") ||
        currentRoute.startsWith("chat_thread") ||
        currentRoute == CoffeeCallRoutes.PROFILE_EDIT
    )
    val shouldShowBottomNavigation = !isTabBarHidden && !isDetailOrChat

    LaunchedEffect(isDetailOrChat) {
        navManager.setTabBarHidden(isDetailOrChat)
    }

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
                    onNavigateToDrifts = {
                        navManager.clearInterestFilter()
                        navController.navigate(CoffeeCallRoutes.DRIFTS) {
                            popUpTo(navController.graph.startDestinationId) {
                                saveState = true
                            }
                            launchSingleTop = true
                            restoreState = true
                        }
                    },
                    onInterestSelected = { interest ->
                        navManager.setActiveInterestFilter(interest)
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
            composable(CoffeeCallRoutes.DRIFTS) {
                DriftsScreen(
                    onDriftClick = { id ->
                        navController.navigate("drift_detail/$id")
                    },
                    onNavigateToChat = { threadId ->
                        navController.navigate("chat_thread/$threadId")
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
                    onDriftClick = { id ->
                        navController.navigate("drift_detail/$id")
                    },
                    onSignOut = onSignOut,
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
                    },
                    onNavigateToChat = { id ->
                        navController.navigate("chat_thread/$id")
                    }
                )
            }
        }

        if (!isOnline) {
            Box(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .fillMaxWidth()
                    .statusBarsPadding()
                    .padding(horizontal = CoffeeSpacing.screen)
                    .padding(top = CoffeeSpacing.sm),
                contentAlignment = Alignment.Center
            ) {
                Surface(
                    shape = CircleShape,
                    color = CoffeePeach.copy(alpha = 0.9f),
                    border = BorderStroke(1.dp, Color.White.copy(alpha = 0.3f)),
                    shadowElevation = 8.dp
                ) {
                    Text(
                        text = "⚠️ Device is offline. Using local caches.",
                        color = Color.White,
                        style = MaterialTheme.typography.labelMedium,
                        fontWeight = FontWeight.Bold,
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
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

        if (shouldShowBottomNavigation) {
            BottomFade()
            CoffeeBottomNavigation(
                destinations = CoffeeCallDestinations,
                selectedRoute = selectedDestination.route,
                onDestinationClick = { destination ->
                    if (destination.route == CoffeeCallRoutes.DRIFTS) {
                        navManager.clearInterestFilter()
                    }
                    navController.navigate(destination.route) {
                        popUpTo(navController.graph.startDestinationId) {
                            saveState = true
                        }
                        launchSingleTop = true
                        restoreState = true
                    }
                },
                onCreateClick = { showCreateSheet = true },
                modifier = Modifier.align(Alignment.BottomCenter)
            )
        }

        if (showCreateSheet) {
            Surface(
                modifier = Modifier
                    .align(Alignment.Center)
                    .fillMaxSize(),
                color = CoffeeBackground
            ) {
                CreateScreen(
                    onCreated = {
                        showCreateSheet = false
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
        }
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
    onCreateClick: () -> Unit,
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
        destinations.forEachIndexed { index, destination ->
            if (index == 2) {
                CoffeeCreateNavigationAction(
                    onClick = onCreateClick,
                    modifier = Modifier.weight(1f)
                )
            }

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
private fun CoffeeCreateNavigationAction(
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier,
        contentAlignment = Alignment.Center
    ) {
        Surface(
            onClick = onClick,
            modifier = Modifier
                .size(64.dp)
                .shadow(
                    elevation = 16.dp,
                    shape = CircleShape,
                    ambientColor = CoffeePrimary.copy(alpha = 0.16f),
                    spotColor = CoffeePrimary.copy(alpha = 0.20f)
                ),
            shape = CircleShape,
            color = CoffeePrimary,
            border = BorderStroke(2.dp, CoffeeTextOnBrand.copy(alpha = 0.08f))
        ) {
            Box(
                modifier = Modifier.fillMaxSize(),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = CoffeeIcons.create,
                    contentDescription = "Create",
                    tint = CoffeeTextOnBrand,
                    modifier = Modifier.size(28.dp)
                )
            }
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
    val iconTint = if (selected) CoffeePrimary else CoffeeMuted

    Surface(
        onClick = onClick,
        modifier = modifier
            .height(CoffeeSpacing.primaryButtonHeight)
            .padding(horizontal = 2.dp),
        shape = CoffeeShapes.large,
        color = Color.Transparent
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 6.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Icon(
                imageVector = destination.icon,
                contentDescription = destination.label,
                tint = iconTint,
                modifier = Modifier.size(22.dp)
            )
            Spacer(modifier = Modifier.height(2.dp))
            Text(
                text = destination.label,
                style = MaterialTheme.typography.labelSmall,
                color = iconTint,
                fontWeight = if (selected) FontWeight.Bold else FontWeight.Medium,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
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
                .padding(top = CoffeeSpacing.xl)
        ) {
            CoffeeBottomNavigation(
                destinations = CoffeeCallDestinations,
                selectedRoute = CoffeeCallRoutes.DISCOVERY,
                onDestinationClick = {},
                onCreateClick = {}
            )
        }
    }
}
